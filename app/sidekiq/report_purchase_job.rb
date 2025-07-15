class ReportPurchaseJob
  include Sidekiq::Job
  sidekiq_options retry: 3

  def perform(creator_id, product_id, purchase_item_id)
    creator = User.find_by(id: creator_id)
    product = Product.find_by(id: product_id)
    purchase_item = PurchaseItem.find_by(id: purchase_item_id)

    return unless creator && product && purchase_item

    creator_email = creator.email
    product_name = product.name
    quantity_sold = purchase_item.quantity

    puts "--- INICIANDO REPORTE DE COMPRA ---"
    puts "Producto: '#{product_name}' (ID: #{product.id})"
    puts "Cantidad vendida: #{quantity_sold}"
    puts "Creador del producto: #{creator_email} (ID: #{creator.id})"
    puts "TAREA: Enviar un email de notificación a #{creator_email}."
    puts "--- REPORTE FINALIZADO ---"
  end
end
