

const initHeroFx = () => {
  const words = [
    "participativa",
    "inclusiva",
    "aberta",
    "democrática",
    "transparente",
    "acessível"
  ];

  let index = 0;
  const element = document.getElementById("rotated-words");

  if (element) {
    console.log("Hero FX inicializado - elemento encontrado");
    
    // Palavra inicial
    element.textContent = words[0];
    element.style.opacity = 1;

    // Muda a palavra a cada 2.5 segundos com fade
    setInterval(() => {
      index = (index + 1) % words.length;

      // Fade out
      element.style.opacity = 0;

      // Troca a palavra e fade in
      setTimeout(() => {
        element.textContent = words[index];
        element.style.opacity = 1;
      }, 600); // tempo do fade
    }, 2500);
  } else {
    console.warn("Hero FX: elemento #rotated-words não encontrado");
  }
};


if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initHeroFx);
} else {
  initHeroFx();
}