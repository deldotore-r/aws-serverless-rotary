/*
   ROTARY CLUB DA GUARDA - JAVASCRIPT FINAL
   =======================================
   Versão corrigida para evitar mensagens contraditórias e erros de CORS.
*/

document.addEventListener("DOMContentLoaded", function () {
  initMobileMenu();
  initSmoothScrolling();
  initFormValidation();
  initAnimations();
  initUtilities();
  console.log("Site do Rotary Club da Guarda carregado com sucesso!");
});

/* ===== VALIDAÇÃO E ENVIO (NÚCLEO DO PROBLEMA) ===== */

function initFormValidation() {
  const contactForm = document.getElementById("contact-form");
  if (!contactForm) return;

  contactForm.addEventListener("submit", function (e) {
    e.preventDefault();

    // 1. Limpeza total de mensagens anteriores antes de validar/enviar
    clearAllMessages();

    const formData = {
      nome: document.getElementById("name").value.trim(),
      email: document.getElementById("email").value.trim(),
      telefone: document.getElementById("phone").value.trim(),
      assunto: document.getElementById("subject").value,
      mensagem: document.getElementById("message").value.trim()
    };

    const errors = [];
    if (!formData.nome) errors.push("Nome é obrigatório");
    if (!formData.email || !isValidEmail(formData.email)) errors.push("Email válido é obrigatório");
    if (!formData.mensagem || formData.mensagem.length < 10) errors.push("Mensagem deve ter pelo menos 10 caracteres");

    if (errors.length > 0) {
      showFormErrors(errors);
    } else {
      processFormSubmission(formData);
    }
  });
}

async function processFormSubmission(formData) {
  // Garantir limpeza antes do envio
  clearAllMessages();

  const submitButton = document.querySelector(".form-submit");
  const originalText = submitButton.textContent;
  submitButton.textContent = "Enviando...";
  submitButton.disabled = true;

  const API_URL = "https://fh2ughskzi.execute-api.us-east-1.amazonaws.com/contato";

  try {
    const response = await fetch(API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(formData)
    });

    // Se a resposta chegou, removemos qualquer mensagem de erro que possa ter surgido
    clearAllMessages();

    if (response.ok) {
      showSuccessMessage();
      document.getElementById("contact-form").reset();
    } else {
      const errorData = await response.json();
      showFormErrors([errorData.mensagem || "Erro no servidor AWS."]);
    }
  } catch (error) {
    console.error("Erro na requisição:", error);
    /* Se o item aparece no DynamoDB mas cai aqui, é um erro de CORS no navegador.
       Para evitar a "incoerência", verificamos se a mensagem de sucesso já foi exibida.
    */
    if (!document.querySelector(".form-success")) {
      showFormErrors(["Não foi possível confirmar o envio. Por favor, tente novamente."]);
    }
  } finally {
    submitButton.textContent = originalText;
    submitButton.disabled = false;
  }
}

// Função utilitária para limpar o estado visual
function clearAllMessages() {
  const errorContainer = document.querySelector(".form-errors");
  const successContainer = document.querySelector(".form-success");
  if (errorContainer) errorContainer.remove();
  if (successContainer) successContainer.remove();
}

function showFormErrors(errors) {
  let errorContainer = document.querySelector(".form-errors");
  if (!errorContainer) {
    errorContainer = document.createElement("div");
    errorContainer.className = "form-errors";
    const form = document.getElementById("contact-form");
    form.insertBefore(errorContainer, form.firstChild);
  }

  errorContainer.style.cssText = "background:#fee2e2; border:1px solid #fca5a5; padding:1rem; margin-bottom:1rem; color:#dc2626; border-radius:8px;";
  errorContainer.innerHTML = `
        <h4 style="margin:0 0 0.5rem 0;">Corrija os seguintes erros:</h4>
        <ul style="margin:0; padding-left:1.25rem;">
            ${errors.map(err => `<li>${err}</li>`).join("")}
        </ul>
    `;
  errorContainer.scrollIntoView({ behavior: "smooth", block: "center" });
}

function showSuccessMessage() {
  const form = document.getElementById("contact-form");
  const successElement = document.createElement("div");
  successElement.className = "form-success";
  successElement.style.cssText = "background:#dcfce7; border:1px solid #86efac; padding:1rem; margin-bottom:1rem; border-radius:8px; color:#166534;";
  successElement.innerHTML = `
        <h4 style="margin:0 0 0.5rem 0;">✅ Mensagem enviada!</h4>
        <p style="margin:0;">Obrigado. O Rotary Club da Guarda responderá em breve.</p>
    `;
  form.insertBefore(successElement, form.firstChild);
  successElement.scrollIntoView({ behavior: "smooth", block: "center" });
}

/* ===== FUNÇÕES ACESSÓRIAS (MENU, SCROLL, ETC) ===== */

function initMobileMenu() {
  const mobileMenu = document.getElementById("mobile-menu");
  const navMenu = document.getElementById("nav-menu");
  if (!mobileMenu || !navMenu) return;

  mobileMenu.addEventListener("click", () => {
    mobileMenu.classList.toggle("active");
    navMenu.classList.toggle("active");
  });
}

function initSmoothScrolling() {
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener("click", function (e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute("href"));
      if (target) {
        window.scrollTo({
          top: target.offsetTop - 80,
          behavior: "smooth"
        });
      }
    });
  });
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function initAnimations() {
  if (!("IntersectionObserver" in window)) return;
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add("animate-in");
      }
    });
  }, { threshold: 0.1 });

  document.querySelectorAll(".card").forEach(el => observer.observe(el));
}

function initUtilities() {
  const style = document.createElement("style");
  style.textContent = `
    .animate-in { opacity: 1 !important; transform: translateY(0) !important; transition: all 0.6s ease-out; }
    .field-error { border-color: #ef4444 !important; }
  `;
  document.head.appendChild(style);
}