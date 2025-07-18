document.addEventListener('DOMContentLoaded', () => {
  const correctPassword = "puntospoint";
  
  let enteredPassword = prompt("Verificación: Por favor, ingresa la clave para acceder:");
  
  while (enteredPassword !== correctPassword) {
    alert("Clave incorrecta. No puedes ver el contenido.");
    enteredPassword = prompt("Verificación: Por favor, ingresa la clave para acceder:");
  }

  window.location.href = "/api-docs";
});
