class Api::V1::AnalyticsController < ApplicationController
  rate_limit to: 10, within: 30.seconds, only: :most_purchased_products_by_category, with: -> { render json: { error: "Demasiadas peticiones" }, status: 429 }, store: cache_store
  rate_limit to: 10, within: 30.seconds, only: :top_revenue_products_by_category, with: -> { render json: { error: "Demasiadas peticiones" }, status: 429 }, store: cache_store
  rate_limit to: 5, within: 30.seconds, only: :purchases_list, with: -> { render json: { error: "Demasiadas peticiones" }, status: 429 }, store: cache_store
  rate_limit to: 5, within: 30.seconds, only: :purchase_counts_by_granularity, with: -> { render json: { error: "Demasiadas peticiones" }, status: 429 }, store: cache_store
  before_action :authenticate_user!
  before_action :authorize_admin!

  # a. Obtener el Producto más comprado por cada categoría
  def most_purchased_products_by_category
    result = Rails.cache.fetch("analytics/most_purchased_by_category", expires_in: 15.minutes) do
      # 1. Obtenemos una lista plana de todos los productos vendidos con sus totales,
      # agrupados por categoría. Esta es una única y eficiente consulta a la BD.
      products_sold = Product
        .joins(:purchase_items, :categories)
        .group("categories.name", "products.id")
        .select(
          "categories.name AS category_name",
          "products.id AS product_id",
          "products.name AS product_name",
          "SUM(purchase_items.quantity) AS total_quantity"
        )

      # 2. Usamos `group_by` de Ruby para agrupar los resultados en un hash por categoría.
      # El resultado es: { "Categoría A" => [producto1, producto2], "Categoría B" => [producto3] }
      grouped_by_category = products_sold.group_by(&:category_name)

      # 3. Usamos `transform_values` para iterar sobre cada lista de productos y encontrar
      # el que tiene la mayor cantidad vendida usando `max_by`.
      grouped_by_category.transform_values do |products|
        top_product = products.max_by(&:total_quantity)
        {
          id: top_product.product_id,
          name: top_product.product_name,
          total_quantity_sold: top_product.total_quantity.to_i
        }
      end
    end

    render json: result, status: :ok
  end


  # b. Obtener los 3 Productos que más han recaudado ($) por categoría
  def top_revenue_products_by_category
    result = Rails.cache.fetch("analytics/top_revenue_by_category", expires_in: 15.minutes) do
      # 1. Similar al anterior, obtenemos una lista plana de productos y su recaudación.
      # Usamos el alias `calculated_revenue` para evitar colisiones.
      products_revenue = Product
        .joins(:purchase_items, :categories)
        .group("categories.name", "products.id")
        .select(
          "categories.name AS category_name",
          "products.id AS product_id",
          "products.name AS product_name",
          "SUM(purchase_items.total_price) AS calculated_revenue"
        )

      # 2. Agrupamos los resultados por nombre de categoría.
      grouped_by_category = products_revenue.group_by(&:category_name)

      # 3. Transformamos los valores: para cada lista de productos, la ordenamos
      # por recaudación (de mayor a menor) y tomamos los 3 primeros con `first(3)`.
      grouped_by_category.transform_values do |products|
        top_3_products = products.sort_by(&:calculated_revenue).reverse.first(3)

        # Mapeamos el resultado para darle el formato de salida deseado.
        top_3_products.map do |product|
          {
            id: product.product_id,
            name: product.product_name,
            total_revenue: product.calculated_revenue.to_f
          }
        end
      end
    end

    render json: result, status: :ok
  end


  # app/controllers/api/v1/analytics_controller.rb
  # c. Obtener listado de compras según parámetros
  def purchases_list
    cache_key = [ "analytics/purchases_list", params.permit(:category_id, :admin_id, :purchase_date_from, :purchase_date_to, :customer_id, :page).to_h ]
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      # --- PASO 1: CONSTRUIR LA CONSULTA PARA ENCONTRAR LOS IDs ---
      # Construimos una consulta con todos los joins necesarios solo para filtrar.
      # No nos preocupamos por cargar datos aquí, solo por encontrar las compras correctas.
      purchases_query = Purchase.distinct

      # Filtro por Categoría
      if params[:category_id].present?
        purchases_query = purchases_query.joins(products: :categories)
                                        .where(categories: { id: params[:category_id] })
      end

      # Filtro por Administrador
      if params[:admin_id].present?
        purchases_query = purchases_query.joins(products: :creator)
                            .where(
                              products: { created_by_user_id: params[:admin_id] },
                              users:    { type: "Admin" }
                            )
      end

      # Filtros directos
      if params[:purchase_date_from].present?
        purchases_query = purchases_query.where("purchases.purchase_date >= ?", params[:purchase_date_from])
      end
      if params[:purchase_date_to].present?
        purchases_query = purchases_query.where("purchases.purchase_date <= ?", params[:purchase_date_to])
      end
      if params[:customer_id].present?
        purchases_query = purchases_query.where(customer_id: params[:customer_id])
      end

      # --- PASO 2: EJECUTAR LA CONSULTA Y LUEGO CARGAR LOS DATOS ---
      # Ejecuta la consulta compleja para obtener solo los IDs.
      purchase_ids = purchases_query.page(params[:page]).per(2).pluck(:id)

      next [] if purchase_ids.empty?

      # Inicia una consulta NUEVA y LIMPIA, sin joins, usando los IDs.
      # El .preload aquí funcionará perfectamente porque no hay conflictos.
      final_purchases = Purchase.where(id: purchase_ids)
                                .preload(:customer, purchase_items: { product: :images })
                                .order(purchase_date: :desc)

      # --- PASO 3: CONSTRUIR EL JSON ---
      final_purchases.map { |purchase|
        {
          id: purchase.id,
          customer_name: purchase.customer&.full_name,
          purchase_date: purchase.purchase_date,
          total: purchase.total_amount.to_f,
          status: purchase.status,
          items: purchase.purchase_items.map do |item|
            next if item.product.nil?
            {
              product_name: item.product.name,
              quantity: item.quantity,
              total_price: item.total_price.to_f,
              images: item.product.images.map(&:image_url)
            }
          end.compact
        }
      }
    end

    render json: result, status: :ok
  end


  # d. Obtener cantidad de compras según granularidad
  # GET /api/v1/analytics/purchase_counts_by_granularity
  # d. Obtener cantidad de compras según granularidad.
  # Parámetros: purchase_date_from, purchase_date_to, category_id, customer_id, admin_id, granularity (hour, day, week, year).

  def purchase_counts_by_granularity
    # Validar parámetro de granularidad
    valid_granularities = %w[hour day week month year] # Añadí 'month' como opción útil

    granularity = params[:granularity].to_s.downcase

    # Comprobamos que el parámetro de granularidad sea válido
    unless valid_granularities.include?(granularity)
      # Si no es válido, retornamos un error
      return render json: { error: "Granularidad inválida. Use: #{valid_granularities.join(', ')}" }, status: :bad_request
    end

    cache_key = [ "analytics/purchase_counts", params.permit(:category_id, :admin_id, :purchase_date_from, :purchase_date_to, :customer_id, :granularity).to_h ]
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      # Obtener todas las compras
      purchases = Purchase.all

      # Aplicar filtros según los parámetros de fecha
      if params[:purchase_date_from].present?
        purchases = purchases.where("purchase_date >= ?", params[:purchase_date_from])
      end

      if params[:purchase_date_to].present?
        purchases = purchases.where("purchase_date <= ?", params[:purchase_date_to])
      end

      # Filtrar por customer_id si está presente
      if params[:customer_id].present?
        purchases = purchases.where(customer_id: params[:customer_id])
      end

      # Filtro por Administrador
      if params[:admin_id].present?
        purchases = purchases.joins(products: :creator)
                            .where(
                              products: { created_by_user_id: params[:admin_id] },
                              users:    { type: "Admin" }
                            )
      end

      # Filtrar por category_id si está presente y si se trata de productos
      if params[:category_id].present?
        purchases = purchases.joins(products: :categories)
                            .where(categories: { id: params[:category_id] })
      end

      # Agrupar por granularidad, utilizando funciones de fecha
      # Para PostgreSQL, utilizamos DATE_TRUNC
      grouped_counts = purchases.distinct.group("DATE_TRUNC('#{granularity}', purchases.purchase_date)").count

      # Formatear la respuesta para el gráfico
      grouped_counts.transform_keys do |key|
        # La clave `key` será un objeto Time o DateTime. La formateamos según la granularidad seleccionada.
        case granularity
        when "hour"
          # Formato para hora: Año-Mes-Día Hora:00
          key.strftime("%Y-%m-%d %H:00")
        when "day"
          # Formato para día: Año-Mes-Día
          key.strftime("%Y-%m-%d")
        when "week"
          # Formato para semana: Año-NúmeroDeSemana (ej. 2024-28)
          key.strftime("%Y-%W")
        when "month"
          # Formato para mes: Año-Mes
          key.strftime("%Y-%m")
        when "year"
          # Formato para año: Año
          key.strftime("%Y")
        else
          key.to_s # Caso por defecto
        end
      end
    end

    # Devolver la respuesta en formato JSON
    render json: result, status: :ok
  end
end
