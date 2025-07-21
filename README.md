Prueba Técnica Puntospoint - Carlos González
Descripción del proyecto.

🚀 Instalación y Puesta en Marcha
Sigue estos pasos para configurar y ejecutar el proyecto en tu entorno de desarrollo local.

Prerrequisitos
Antes de comenzar, asegúrate de que los siguientes servicios estén instalados y corriendo en tu sistema:

PostgreSQL: Como motor de base de datos.

Redis: Como servidor para la gestión de trabajos en segundo plano con Sidekiq.

1. Clonar e Instalar Dependencias
Bash

git clone <URL_DEL_REPOSITORIO>
cd <NOMBRE_DEL_PROYECTO>
bundle install
2. Configuración del Entorno
a. Variables de Entorno (Recomendación)
Para gestionar claves secretas (como la RAILS_MASTER_KEY) en desarrollo de una manera que simule la producción, se recomienda utilizar una herramienta para cargar archivos .env. Una buena opción es Fly.io Env.

b. Credenciales para Gmail
Este comando abrirá el archivo de credenciales encriptado. Se recomienda usar VS Code para una mejor experiencia.

Bash

EDITOR="code --wait" bin/rails credentials:edit
Dentro del archivo, pega la siguiente estructura y complétala con un usuario de Gmail válido y una contraseña de aplicación (no la contraseña normal de la cuenta).

YAML

gmail:
  user_name: "ESPACIO PARA USUARIO VALIDO"
  app_password: "CLAVE DE APLICACIÓN"
Guarda y cierra el archivo en tu editor para que Rails encripte los cambios.

c. Base de Datos (PostgreSQL)
Abre el archivo config/database.yml. En la sección development, asegúrate de que la configuración coincida con tu servidor PostgreSQL local.

YAML

development:
  # ...
  database: puntospoint_development
  user: tu_usuario_de_postgres
  password: tu_contraseña_de_postgres
3. Preparar la Base de Datos
Este comando asegura que la base de datos esté en un estado limpio, aplica todas las migraciones y la puebla con datos iniciales.

Bash

bundle exec rails db:rollback STEP=99 db:migrate db:seed
4. Ejecutar el Proyecto
Necesitarás tener dos terminales abiertas para correr los procesos principales.

Terminal 1: Iniciar Sidekiq
Sidekiq maneja los trabajos en segundo plano, como el envío de correos.

Bash

bundle exec sidekiq
Terminal 2: Iniciar el Servidor de Rails
Este es el servidor principal de la aplicación.

Bash

rails s
¡Y listo! Ahora puedes acceder a la aplicación desde tu navegador en http://localhost:3000.

📄 Documentación de la API (Postman)
Para probar los endpoints de la API, puedes importar la siguiente colección directamente en Postman.

Instrucciones de Importación
Abre tu aplicación de Postman.

Haz clic en el botón Import, ubicado en la esquina superior izquierda.

Selecciona la pestaña Raw text.

Copia y pega todo el contenido del bloque JSON de abajo.

Haz clic en Continue y luego en Import.

La colección ya está configurada para usar variables y guardar automáticamente el token de autenticación después de hacer login.

Colección para Postman
JSON

{
  "info": {
    "_postman_id": "c4a7b8e0-1a2b-3c4d-5e6f-7a8b9c0d1e2f",
    "name": "Prueba Técnica Puntospoint - Carlos González",
    "description": "Colección de Postman para la API de Puntospoint, generada desde la especificación OpenAPI.",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Authentication",
      "description": "Endpoints para registro, login y logout de usuarios.",
      "item": [
        {
          "name": "Iniciar sesión de usuario",
          "event": [
            {
              "listen": "test",
              "script": {
                "exec": [
                  "const authHeader = pm.response.headers.get(\"Authorization\");",
                  "if (authHeader) {",
                  "    const token = authHeader.replace('Bearer ', '');",
                  "    pm.collectionVariables.set(\"jwt_token\", token);",
                  "}"
                ],
                "type": "text/javascript"
              }
            }
          ],
          "request": {
            "method": "POST",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"user\": {\n    \"email\": \"carlos_gonzalez82201@elpoli.edu\",\n    \"password\": \"password\"\n  }\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            },
            "url": {
              "raw": "http://{{baseUrl}}/login",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "login"
              ]
            },
            "description": "Autenticación de usuario con email y password. Retorna un token JWT en el header Authorization."
          },
          "response": []
        },
        {
          "name": "Crear una nueva cuenta de usuario",
          "request": {
            "method": "POST",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"user\": {\n    \"email\": \"user@example.com\",\n    \"password\": \"password\",\n    \"password_confirmation\": \"password\",\n    \"type\": \"User\"\n  }\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            },
            "url": {
              "raw": "http://{{baseUrl}}/signup",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "signup"
              ]
            },
            "description": "Registro de nuevo usuario. Acepta User o Admin como tipo."
          },
          "response": []
        },
        {
          "name": "Cerrar sesión de usuario",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "DELETE",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/logout",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "logout"
              ]
            },
            "description": "Cierra la sesión del usuario actual. Requiere token JWT válido."
          },
          "response": []
        }
      ]
    },
    {
      "name": "User",
      "description": "Operaciones relacionadas con el usuario autenticado.",
      "item": [
        {
          "name": "Obtener datos del usuario autenticado",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/user/current_user",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "user",
                "current_user"
              ]
            }
          },
          "response": []
        }
      ]
    },
    {
      "name": "Analytics",
      "description": "Endpoints para obtener métricas y analíticas de la aplicación.",
      "item": [
        {
          "name": "Productos más comprados por categoría",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/analytics/most_purchased_products_by_category",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "analytics",
                "most_purchased_products_by_category"
              ]
            }
          },
          "response": []
        },
        {
          "name": "Top 3 productos con más ingresos por categoría",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/analytics/top_revenue_products_by_category",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "analytics",
                "top_revenue_products_by_category"
              ]
            }
          },
          "response": []
        },
        {
          "name": "Listado de compras con filtros",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/analytics/purchases_list?purchase_date_from=2025-07-01&purchase_date_to=2025-07-20&category_id=1&customer_id=1&admin_id=1",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "analytics",
                "purchases_list"
              ],
              "query": [
                {
                  "key": "purchase_date_from",
                  "value": "2025-07-01",
                  "description": "Fecha de inicio (YYYY-MM-DD)"
                },
                {
                  "key": "purchase_date_to",
                  "value": "2025-07-20",
                  "description": "Fecha de fin (YYYY-MM-DD)"
                },
                {
                  "key": "category_id",
                  "value": "1",
                  "description": "ID de la categoría para filtrar productos."
                },
                {
                  "key": "customer_id",
                  "value": "1",
                  "description": "ID del cliente (User)."
                },
                {
                  "key": "admin_id",
                  "value": "1",
                  "description": "ID del administrador que creó los productos para filtrar las compras."
                }
              ]
            }
          },
          "response": []
        },
        {
          "name": "Conteo de compras agrupadas por tiempo",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/analytics/purchase_counts_by_granularity?granularity=day&purchase_date_from=2025-07-01&purchase_date_to=2025-07-20",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "analytics",
                "purchase_counts_by_granularity"
              ],
              "query": [
                {
                  "key": "granularity",
                  "value": "day",
                  "description": "(hour, day, week, month, year)"
                },
                {
                  "key": "purchase_date_from",
                  "value": "2025-07-01"
                },
                {
                  "key": "purchase_date_to",
                  "value": "2025-07-20"
                },
                {
                  "key": "category_id",
                  "value": null,
                  "disabled": true
                },
                {
                  "key": "customer_id",
                  "value": null,
                  "disabled": true
                },
                {
                  "key": "admin_id",
                  "value": null,
                  "disabled": true
                }
              ]
            }
          },
          "response": []
        }
      ]
    },
    {
      "name": "Audits",
      "description": "Endpoints para la auditoría de cambios realizados por administradores.",
      "item": [
        {
          "name": "Historial de cambios por Administradores",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/audits/admin_changes",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "audits",
                "admin_changes"
              ]
            },
            "description": "Devuelve una lista de cambios agrupados por administrador. Requiere rol de Admin."
          },
          "response": []
        }
      ]
    },
    {
      "name": "Products",
      "description": "Gestión de productos (CRUD).",
      "item": [
        {
          "name": "Listar todos los productos",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/products",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "products"
              ]
            },
            "description": "Devuelve un array con todos los productos. Requiere rol de Admin."
          },
          "response": []
        },
        {
          "name": "Crear un nuevo producto",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "POST",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"product\": {\n    \"name\": \"Nuevo Producto\",\n    \"description\": \"Descripción del nuevo producto.\",\n    \"price\": 99.99,\n    \"stock\": 100,\n    \"barcode\": \"1234567890123\",\n    \"brand\": \"Marca Ejemplo\",\n    \"model\": \"Modelo-X\",\n    \"status\": \"active\"\n  }\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            },
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/products",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "products"
              ]
            },
            "description": "Crea un producto. El producto se asocia al usuario autenticado (creador)."
          },
          "response": []
        },
        {
          "name": "Obtener un producto por ID",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/products/:id",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "products",
                ":id"
              ],
              "variable": [
                {
                  "key": "id",
                  "value": "1"
                }
              ]
            },
            "description": "Requiere rol de Admin."
          },
          "response": []
        },
        {
          "name": "Actualizar un producto",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "PUT",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"product\": {\n    \"name\": \"Producto Actualizado\",\n    \"price\": 120.50\n  }\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            },
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/products/:id",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "products",
                ":id"
              ],
              "variable": [
                {
                  "key": "id",
                  "value": "1"
                }
              ]
            },
            "description": "Requiere rol de Admin."
          },
          "response": []
        },
        {
          "name": "Eliminar un producto",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "DELETE",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/products/:id",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "products",
                ":id"
              ],
              "variable": [
                {
                  "key": "id",
                  "value": "1"
                }
              ]
            },
            "description": "Requiere rol de Admin. No se puede eliminar si tiene compras asociadas."
          },
          "response": []
        }
      ]
    },
    {
      "name": "Categories",
      "description": "Gestión de categorías (CRUD).",
      "item": [
        {
          "name": "Listar todas las categorías",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/categories",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "categories"
              ]
            }
          },
          "response": []
        },
        {
          "name": "Crear una nueva categoría",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "POST",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"category\": {\n    \"name\": \"Electrónica\",\n    \"description\": \"Dispositivos y accesorios electrónicos.\",\n    \"status\": \"active\"\n  }\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            },
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/categories",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "categories"
              ]
            }
          },
          "response": []
        },
        {
          "name": "Obtener una categoría por ID",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/categories/:id",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "categories",
                ":id"
              ],
              "variable": [
                {
                  "key": "id",
                  "value": "1"
                }
              ]
            }
          },
          "response": []
        },
        {
          "name": "Actualizar una categoría",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "PUT",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"category\": {\n    \"name\": \"Hogar y Cocina\"\n  }\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            },
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/categories/:id",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "categories",
                ":id"
              ],
              "variable": [
                {
                  "key": "id",
                  "value": "1"
                }
              ]
            }
          },
          "response": []
        },
        {
          "name": "Eliminar una categoría",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "DELETE",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/categories/:id",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "categories",
                ":id"
              ],
              "variable": [
                {
                  "key": "id",
                  "value": "1"
                }
              ]
            }
          },
          "response": []
        }
      ]
    },
    {
      "name": "Customers",
      "description": "Gestión de clientes (CRUD).",
      "item": [
        {
          "name": "Listar todos los clientes",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/customers",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "customers"
              ]
            }
          },
          "response": []
        },
        {
          "name": "Crear un nuevo cliente",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "POST",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"customer\": {\n    \"name\": \"Juan\",\n    \"surname\": \"Perez\",\n    \"email\": \"juan.perez@example.com\",\n    \"phone\": \"3001234567\",\n    \"address\": \"Calle Falsa 123\",\n    \"registration_date\": \"2025-07-20\",\n    \"status\": \"active\"\n  }\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            },
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/customers",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "customers"
              ]
            }
          },
          "response": []
        },
        {
          "name": "Obtener un cliente por ID",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/customers/:id",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "customers",
                ":id"
              ],
              "variable": [
                {
                  "key": "id",
                  "value": "1"
                }
              ]
            }
          },
          "response": []
        },
        {
          "name": "Actualizar un cliente",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "PUT",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"customer\": {\n    \"phone\": \"3109876543\"\n  }\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            },
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/customers/:id",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "customers",
                ":id"
              ],
              "variable": [
                {
                  "key": "id",
                  "value": "1"
                }
              ]
            }
          },
          "response": []
        },
        {
          "name": "Eliminar un cliente",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "DELETE",
            "header": [],
            "url": {
              "raw": "http://{{baseUrl}}/api/v1/customers/:id",
              "protocol": "http",
              "host": [
                "{{baseUrl}}"
              ],
              "path": [
                "api",
                "v1",
                "customers",
                ":id"
              ],
              "variable": [
                {
                  "key": "id",
                  "value": "1"
                }
              ]
            }
          },
          "response": []
        }
      ]
    }
  ],
  "variable": [
    {
      "key": "baseUrl",
      "value": "localhost:3000"
    },
    {
      "key": "jwt_token",
      "value": ""
    }
  ],
  "event": [
    {
      "listen": "prerequest",
      "script": {
        "type": "text/javascript",
        "exec": [
          ""
        ]
      }
    },
    {
      "listen": "test",
      "script": {
        "type": "text/javascript",
        "exec": [
          ""
        ]
      }
    }
  ]
}