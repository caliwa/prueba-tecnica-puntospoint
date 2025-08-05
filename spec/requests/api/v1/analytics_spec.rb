require 'rails_helper'

RSpec.describe "Api::V1::AnalyticsController", type: :request do
  let!(:admin) { create(:admin) }
  let!(:another_admin) { create(:admin) }
  let!(:user) { create(:user) }
  let!(:customer1) { create(:customer) }
  let!(:customer2) { create(:customer) }

  let!(:category_tech) { create(:category, name: "Tecnología") }
  let!(:category_home) { create(:category, name: "Hogar") }

  # Productos
  let!(:product_laptop) { create(:product, name: "Laptop Pro", price: 1500, creator: admin, categories: [ category_tech ]) }
  let!(:product_keyboard) { create(:product, name: "Teclado Mecánico", price: 150, creator: admin, categories: [ category_tech ]) }
  let!(:product_lamp) { create(:product, name: "Lámpara LED", price: 80, creator: admin, categories: [ category_home ]) }
  let!(:product_mouse) { create(:product, name: "Mouse Gamer", price: 100, creator: another_admin, categories: [ category_tech ]) }

  # Bloque `before` para crear las transacciones (compras)
  before do
    # Compra 1: Laptop (x2) y Teclado (x5). Ambos productos del mismo admin.
    purchase1 = create(:purchase, customer: customer1, purchase_date: 1.day.ago)
    create(:purchase_item, purchase: purchase1, purchasable: product_laptop, quantity: 2, unit_price: 1500)
    create(:purchase_item, purchase: purchase1, purchasable: product_keyboard, quantity: 5, unit_price: 150)

    # Compra 2: Lámpara (x10)
    purchase2 = create(:purchase, customer: customer2, purchase_date: Time.current)
    create(:purchase_item, purchase: purchase2, purchasable: product_lamp, quantity: 10, unit_price: 80)

    # Compra 3: Mouse (x3)
    purchase3 = create(:purchase, customer: customer1, purchase_date: Time.current)
    create(:purchase_item, purchase: purchase3, purchasable: product_mouse, quantity: 3, unit_price: 100)
  end

  # --- TESTS PARA CADA ENDPOINT ---

  describe "GET /api/v1/analytics/most_purchased_products_by_category" do
    context "cuando el usuario es un administrador" do
      before { get "/api/v1/analytics/most_purchased_products_by_category", headers: auth_headers_for(admin) }

      it "responde con éxito (status 200)" do
        expect(response).to have_http_status(:success)
      end

      it "devuelve el producto MÁS VENDIDO (en cantidad) por categoría" do
        expect(json["Tecnología"]["name"]).to eq("Teclado Mecánico")
        expect(json["Tecnología"]["total_quantity_sold"]).to eq(5)
        expect(json["Hogar"]["name"]).to eq("Lámpara LED")
        expect(json["Hogar"]["total_quantity_sold"]).to eq(10)
      end
    end
  end

  describe "GET /api/v1/analytics/top_revenue_products_by_category" do
    context "cuando el usuario es un administrador" do
      before { get "/api/v1/analytics/top_revenue_products_by_category", headers: auth_headers_for(admin) }

      it "devuelve los productos con MÁS INGRESOS ($) por categoría" do
        top_tech_products = json["Tecnología"]
        expect(top_tech_products.first["name"]).to eq("Laptop Pro")
        expect(top_tech_products.first["total_revenue"]).to eq(3000.0)
      end
    end
  end

  describe "GET /api/v1/analytics/purchases_list" do
    context "cuando el usuario es un administrador" do
      context "cuando no se aplican filtros (prueba de paginación)" do
        it "devuelve la primera página de compras (2 por página)" do
          get "/api/v1/analytics/purchases_list", params: { page: 1 }, headers: auth_headers_for(admin)
          expect(response).to have_http_status(:success)
          expect(json.size).to eq(2)
        end

        it "devuelve la segunda página con la compra restante" do
          get "/api/v1/analytics/purchases_list", params: { page: 2 }, headers: auth_headers_for(admin)
          expect(response).to have_http_status(:success)
          expect(json.size).to eq(1)
        end

        it "devuelve una lista vacía si la página excede el total de registros" do
          get "/api/v1/analytics/purchases_list", params: { page: 3 }, headers: auth_headers_for(admin)
          expect(response).to have_http_status(:success)
          expect(json).to be_empty
        end
      end

      it "filtra por customer_id" do
        get "/api/v1/analytics/purchases_list", params: { customer_id: customer1.id }, headers: auth_headers_for(admin)
        expect(json.size).to eq(2)
      end

      it "filtra por admin_id" do
        get "/api/v1/analytics/purchases_list", params: { admin_id: another_admin.id }, headers: auth_headers_for(admin)
        expect(json.size).to eq(1)
        expect(json.first["items"].first["product_name"]).to eq("Mouse Gamer")
      end

      it "filtra por category_id" do
        get "/api/v1/analytics/purchases_list", params: { category_id: category_home.id }, headers: auth_headers_for(admin)
        expect(json.size).to eq(1)
        expect(json.first["items"].first["product_name"]).to eq("Lámpara LED")
      end
    end
  end

  describe "GET /api/v1/analytics/purchase_counts_by_granularity" do
    context "cuando el usuario es un administrador" do
      it "agrupa las compras por día" do
        get "/api/v1/analytics/purchase_counts_by_granularity", params: { granularity: 'day' }, headers: auth_headers_for(admin)
        today_key = Time.current.strftime("%Y-%m-%d")
        yesterday_key = 1.day.ago.strftime("%Y-%m-%d")
        expect(json[today_key]).to eq(2)
        expect(json[yesterday_key]).to eq(1)
      end

      it "devuelve error con granularidad inválida" do
        get "/api/v1/analytics/purchase_counts_by_granularity", params: { granularity: 'milenio' }, headers: auth_headers_for(admin)
        expect(response).to have_http_status(:bad_request)
      end

      it "filtra correctamente las cuentas por admin_id" do
         get "/api/v1/analytics/purchase_counts_by_granularity", params: { granularity: 'day', admin_id: admin.id }, headers: auth_headers_for(admin)
         today_key = Time.current.strftime("%Y-%m-%d")
         yesterday_key = 1.day.ago.strftime("%Y-%m-%d")
         expect(json[today_key]).to eq(1)
         expect(json[yesterday_key]).to eq(1)
      end
    end
  end

  context "cuando el usuario no es un administrador" do
    it "devuelve prohibido (status 403) para todos los endpoints" do
      get "/api/v1/analytics/most_purchased_products_by_category", headers: auth_headers_for(user)
      expect(response).to have_http_status(:forbidden)

      get "/api/v1/analytics/top_revenue_products_by_category", headers: auth_headers_for(user)
      expect(response).to have_http_status(:forbidden)

      get "/api/v1/analytics/purchases_list", headers: auth_headers_for(user)
      expect(response).to have_http_status(:forbidden)

      get "/api/v1/analytics/purchase_counts_by_granularity", params: { granularity: 'day' }, headers: auth_headers_for(user)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
