# frozen_string_literal: true

puts "Limpiando la base de datos..."
PurchaseItem.destroy_all
Purchase.destroy_all
Categorization.destroy_all
Image.destroy_all
Product.destroy_all
Category.destroy_all
Customer.destroy_all
User.destroy_all

puts "Creando usuarios..."
admin_user = Admin.find_or_create_by!(email: "admin@example.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
end

regular_user = User.find_or_create_by!(email: "user@example.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
end
puts "Usuarios creados: #{User.count}"

puts "Creando clientes..."
customer1 = Customer.create!(
  name: "Juan",
  surname: "Pérez",
  email: "juan.perez@example.com",
  phone: "555-123-4567",
  address: "Calle Falsa 123, Ciudad de México, México",
  registration_date: DateTime.new(2023, 1, 15, 10, 30, 0),
  status: "active"
)
customer2 = Customer.create!(
  name: "María",
  surname: "González",
  email: "maria.gonzalez@example.com",
  phone: "555-987-6543",
  address: "Av. Siempre Viva 742, Springfield, USA",
  registration_date: DateTime.new(2022, 11, 1, 14, 0, 0),
  status: "active"
)
customer3 = Customer.create!(
  name: "Pedro",
  surname: "Ramírez",
  email: "pedro.ramirez@example.com",
  phone: "555-333-2211",
  address: "Carrera 5 # 10-20, Bogotá, Colombia",
  registration_date: DateTime.new(2024, 3, 10, 9, 15, 0),
  status: "inactive"
)
puts "Clientes creados: #{Customer.count}"

puts "Creando categorías..."
category1 = Category.create!(name: "Electrónica", description: "Productos electrónicos de consumo.", status: "active")
category2 = Category.create!(name: "Ropa y Accesorios", description: "Prendas de vestir y accesorios.", status: "active")
category3 = Category.create!(name: "Hogar y Jardín", description: "Artículos para el hogar y jardinería.", status: "active")
category4 = Category.create!(name: "Libros", description: "Libros de diversos géneros.", status: "inactive")
puts "Categorías creadas: #{Category.count}"

puts "Creando productos..."
product1 = Product.create!(
  creator: admin_user,
  name: "Smartphone X",
  description: "Último modelo de smartphone con cámara de alta resolución.",
  price: 799.99,
  stock: 50,
  barcode: "1234567890123",
  brand: "TechCo",
  model: "X-2025",
  creation_date: DateTime.new(2024, 1, 10, 11, 0, 0),
  status: "active"
)

product2 = Product.create!(
  creator: regular_user,
  name: "Auriculares Bluetooth",
  description: "Auriculares inalámbricos con cancelación de ruido.",
  price: 99.50,
  stock: 120,
  barcode: "9876543210987",
  brand: "SoundWave",
  model: "SW-Pro",
  creation_date: DateTime.new(2023, 5, 20, 16, 45, 0),
  status: "active"
)

product3 = Product.create!(
  creator: regular_user,
  name: "Camiseta Algodón Premium",
  description: "Camiseta 100% algodón orgánico, talla M.",
  price: 25.00,
  stock: 200,
  barcode: "1122334455667",
  brand: "EcoWear",
  model: "Basic Tee",
  creation_date: DateTime.new(2023, 8, 1, 9, 0, 0),
  status: "active"
)

product4 = Product.create!(
  creator: admin_user,
  name: "Set de Herramientas",
  description: "Kit completo de herramientas para reparaciones en el hogar.",
  price: 75.00,
  stock: 30,
  barcode: "2233445566778",
  brand: "HandyTools",
  model: "HomeKit",
  creation_date: DateTime.new(2024, 2, 1, 13, 20, 0),
  status: "active"
)

product5 = Product.create!(
  creator: admin_user,
  name: "Maceta Decorativa",
  description: "Maceta de cerámica para interiores, diseño moderno.",
  price: 15.75,
  stock: 0,
  barcode: "3344556677889",
  brand: "GreenLiving",
  model: "Ceramic L",
  creation_date: DateTime.new(2023, 10, 15, 17, 10, 0),
  status: "inactive"
)

product6 = Product.create!(
  creator: regular_user,
  name: "Laptop Ultraligera",
  description: "Laptop potente y ligera para trabajo y estudio.",
  price: 1200.00,
  stock: 25,
  barcode: "4455667788990",
  brand: "ProTech",
  model: "UltraBook Pro",
  creation_date: DateTime.new(2024, 6, 1, 8, 30, 0),
  status: "active"
)
puts "Productos creados: #{Product.count}"

puts "Creando imágenes..."
Image.create!(imageable: product1, image_url: "http://example.com/images/smartphone_x.jpg", description: "Vista frontal del Smartphone X", upload_date: DateTime.now - 1.month)
Image.create!(imageable: product1, image_url: "http://example.com/images/smartphone_n.jpg", description: "Vista trasera del Smartphone N", upload_date: DateTime.now - 1.month)
Image.create!(imageable: product2, image_url: "http://example.com/images/auriculares_bt.jpg", description: "Auriculares con estuche de carga", upload_date: DateTime.now - 2.months)
Image.create!(imageable: product6, image_url: "http://example.com/images/laptop_ultraligera.jpg", description: "Laptop con pantalla encendida", upload_date: DateTime.now - 1.week)
puts "Imágenes creadas: #{Image.count}"

# --- Creación de Categorizaciones (Asignar Productos a Categorías) ---
puts "Creando categorizaciones..."
Categorization.create!(category: category1, categorizable: product1)
Categorization.create!(category: category1, categorizable: product2)
Categorization.create!(category: category2, categorizable: product3)
Categorization.create!(category: category3, categorizable: product4)
Categorization.create!(category: category3, categorizable: product5)
Categorization.create!(category: category1, categorizable: product6)
puts "Categorizaciones creadas: #{Categorization.count}"

puts "Creando compras y artículos de compra..."
purchase1 = Purchase.create!(customer: customer1, purchase_date: DateTime.new(2024, 6, 1, 10, 0, 0), total: 0, status: "confirmed", payment_method: "credit_card", shipping_address: customer1.address)
purchase1.add_product(product1, 1, product1.price, discount: 5.00, tax: 10.00)
purchase1.add_product(product2, 2, product2.price)
purchase1.update_total!

purchase2 = Purchase.create!(customer: customer2, purchase_date: DateTime.new(2024, 7, 5, 14, 30, 0), total: 0, status: "pending", payment_method: "paypal", shipping_address: customer2.address)
purchase2.add_product(product3, 3, product3.price)
purchase2.update_total!

purchase3 = Purchase.create!(customer: customer1, purchase_date: DateTime.new(2024, 5, 20, 9, 45, 0), total: 0, status: "delivered", payment_method: "bank_transfer", shipping_address: customer1.address)
purchase3.add_product(product4, 1, product4.price, tax: 5.00)
purchase3.add_product(product6, 1, product6.price, discount: 50.00)
purchase3.update_total!

purchase4 = Purchase.create!(customer: customer3, purchase_date: DateTime.new(2024, 4, 1, 11, 0, 0), total: 0, status: "cancelled", payment_method: "cash", shipping_address: customer3.address)
purchase4.update_total!

puts "Compras creadas: #{Purchase.count}"
puts "Artículos de compra creados: #{PurchaseItem.count}"

puts "Datos de prueba (seed data) creados exitosamente."
