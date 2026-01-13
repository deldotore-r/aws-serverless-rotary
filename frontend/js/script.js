/*
   ROTARY CLUB DA GUARDA - JAVASCRIPT
   ===================================
   
   Este arquivo contém toda a funcionalidade JavaScript para o site institucional 
   do Rotary Club da Guarda.
   
   Funcionalidades incluídas:
   1. Menu mobile responsivo
   2. Validação de formulários
   3. Smooth scrolling
   4. Animações e interações
   5. Utilitários gerais
   
   Comentários detalhados para facilitar a compreensão e manutenção.
*/

/* ===== FUNÇÕES DE INICIALIZAÇÃO ===== */

// Função que executa quando o DOM estiver completamente carregado
document.addEventListener("DOMContentLoaded", function () {
  // Inicializar todas as funcionalidades
  initMobileMenu();
  initSmoothScrolling();
  initFormValidation();
  initAnimations();
  initUtilities();

  console.log("Site do Rotary Club da Guarda carregado com sucesso!");
});

/* ===== MENU MOBILE RESPONSIVO ===== */

/**
 * Inicializa o menu mobile hamburger
 * Permite abrir/fechar o menu em dispositivos móveis
 */
function initMobileMenu() {
  // Selecionar elementos do menu
  const mobileMenu = document.getElementById("mobile-menu");
  const navMenu = document.getElementById("nav-menu");

  // Verificar se os elementos existem na página
  if (!mobileMenu || !navMenu) {
    return; // Sair da função se os elementos não existirem
  }

  // Adicionar evento de clique no botão hamburger
  mobileMenu.addEventListener("click", function () {
    // Alternar classe 'active' no menu mobile
    mobileMenu.classList.toggle("active");
    navMenu.classList.toggle("active");

    // Melhorar acessibilidade - atualizar atributo aria-expanded
    const isExpanded = navMenu.classList.contains("active");
    mobileMenu.setAttribute("aria-expanded", isExpanded);

    // Prevenir scroll do body quando menu está aberto
    if (isExpanded) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
  });

  // Fechar menu quando clicar num link (para navegação suave)
  const navLinks = navMenu.querySelectorAll(".nav-link");
  navLinks.forEach((link) => {
    link.addEventListener("click", function () {
      // Fechar menu apenas se for um link interno (não externo)
      if (!this.getAttribute("href").startsWith("http")) {
        mobileMenu.classList.remove("active");
        navMenu.classList.remove("active");
        document.body.style.overflow = "";
        mobileMenu.setAttribute("aria-expanded", "false");
      }
    });
  });

  // Fechar menu quando clicar fora dele
  document.addEventListener("click", function (event) {
    const isClickInsideMenu =
      navMenu.contains(event.target) || mobileMenu.contains(event.target);

    if (!isClickInsideMenu && navMenu.classList.contains("active")) {
      mobileMenu.classList.remove("active");
      navMenu.classList.remove("active");
      document.body.style.overflow = "";
      mobileMenu.setAttribute("aria-expanded", "false");
    }
  });

  // Ajustar menu quando a janela for redimensionada
  window.addEventListener("resize", function () {
    // Se a tela ficar grande (desktop), garantir que o menu seja fechado
    if (window.innerWidth > 768) {
      mobileMenu.classList.remove("active");
      navMenu.classList.remove("active");
      document.body.style.overflow = "";
      mobileMenu.setAttribute("aria-expanded", "false");
    }
  });
}

/* ===== SMOOTH SCROLLING ===== */

/**
 * Inicializa o scrolling suave para links âncora
 * Melhora a experiência do usuário na navegação
 */
function initSmoothScrolling() {
  // Selecionar todos os links que começam com #
  const anchorLinks = document.querySelectorAll('a[href^="#"]');

  anchorLinks.forEach((link) => {
    link.addEventListener("click", function (e) {
      // Obter o destino do link
      const targetId = this.getAttribute("href");

      // Verificar se é apenas # (topo da página)
      if (targetId === "#") {
        e.preventDefault();
        window.scrollTo({
          top: 0,
          behavior: "smooth",
        });
        return;
      }

      // Procurar elemento de destino
      const targetElement = document.querySelector(targetId);

      if (targetElement) {
        e.preventDefault();

        // Calcular posição considerando o header fixo
        const headerHeight = document.querySelector(".header").offsetHeight;
        const targetPosition = targetElement.offsetTop - headerHeight - 20;

        // Scroll suave para a posição
        window.scrollTo({
          top: targetPosition,
          behavior: "smooth",
        });
      }
    });
  });
}

/* ===== VALIDAÇÃO DE FORMULÁRIOS ===== */

/**
 * Inicializa a validação do formulário de contato
 * Garante que os dados sejam válidos antes do envio
 */
function initFormValidation() {
  const contactForm = document.getElementById("contact-form");

  if (!contactForm) {
    return; // Sair se o formulário não existir na página
  }

  contactForm.addEventListener("submit", function (e) {
    e.preventDefault(); // Prevenir envio padrão do formulário

    // Obter valores dos campos
    const formData = {
      name: document.getElementById("name").value.trim(),
      email: document.getElementById("email").value.trim(),
      phone: document.getElementById("phone").value.trim(),
      subject: document.getElementById("subject").value,
      message: document.getElementById("message").value.trim(),
    };

    // Validar campos obrigatórios
    const errors = [];

    if (!formData.name) {
      errors.push("Nome é obrigatório");
    }

    if (!formData.email) {
      errors.push("Email é obrigatório");
    } else if (!isValidEmail(formData.email)) {
      errors.push("Email deve ter um formato válido");
    }

    if (!formData.subject) {
      errors.push("Assunto é obrigatório");
    }

    if (!formData.message) {
      errors.push("Mensagem é obrigatória");
    } else if (formData.message.length < 10) {
      errors.push("Mensagem deve ter pelo menos 10 caracteres");
    }

    // Mostrar erros ou processar formulário
    if (errors.length > 0) {
      showFormErrors(errors);
    } else {
      processFormSubmission(formData);
    }
  });

  // Adicionar validação em tempo real nos campos
  const requiredFields = ["name", "email", "subject", "message"];
  requiredFields.forEach((fieldId) => {
    const field = document.getElementById(fieldId);
    if (field) {
      field.addEventListener("blur", function () {
        validateField(this);
      });

      field.addEventListener("input", function () {
        removeFieldError(this);
      });
    }
  });
}

/**
 * Valida se um email tem formato correto
 * @param {string} email - Email para validar
 * @returns {boolean} - true se válido, false se inválido
 */
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Valida um campo individual
 * @param {HTMLElement} field - Campo a ser validado
 */
function validateField(field) {
  const value = field.value.trim();
  let isValid = true;
  let errorMessage = "";

  // Validação específica por campo
  switch (field.id) {
    case "name":
      if (!value) {
        isValid = false;
        errorMessage = "Nome é obrigatório";
      }
      break;

    case "email":
      if (!value) {
        isValid = false;
        errorMessage = "Email é obrigatório";
      } else if (!isValidEmail(value)) {
        isValid = false;
        errorMessage = "Email deve ter um formato válido";
      }
      break;

    case "subject":
      if (!value) {
        isValid = false;
        errorMessage = "Assunto é obrigatório";
      }
      break;

    case "message":
      if (!value) {
        isValid = false;
        errorMessage = "Mensagem é obrigatória";
      } else if (value.length < 10) {
        isValid = false;
        errorMessage = "Mensagem deve ter pelo menos 10 caracteres";
      }
      break;
  }

  // Mostrar ou remover erro
  if (!isValid) {
    showFieldError(field, errorMessage);
  } else {
    removeFieldError(field);
  }

  return isValid;
}

/**
 * Mostra erro em um campo específico
 * @param {HTMLElement} field - Campo com erro
 * @param {string} message - Mensagem de erro
 */
function showFieldError(field, message) {
  // Remover erro anterior se existir
  removeFieldError(field);

  // Adicionar classe de erro ao campo
  field.classList.add("field-error");

  // Criar elemento de erro
  const errorElement = document.createElement("div");
  errorElement.className = "field-error-message";
  errorElement.textContent = message;
  errorElement.style.color = "#ef4444";
  errorElement.style.fontSize = "0.875rem";
  errorElement.style.marginTop = "0.25rem";

  // Inserir após o campo
  field.parentNode.insertBefore(errorElement, field.nextSibling);
}

/**
 * Remove erro de um campo específico
 * @param {HTMLElement} field - Campo para remover erro
 */
function removeFieldError(field) {
  field.classList.remove("field-error");

  const errorElement = field.parentNode.querySelector(".field-error-message");
  if (errorElement) {
    errorElement.remove();
  }
}

/**
 * Mostra erros gerais do formulário
 * @param {Array} errors - Array com mensagens de erro
 */
function showFormErrors(errors) {
  // Criar ou atualizar área de erros
  let errorContainer = document.querySelector(".form-errors");

  if (!errorContainer) {
    errorContainer = document.createElement("div");
    errorContainer.className = "form-errors";

    const form = document.getElementById("contact-form");
    form.insertBefore(errorContainer, form.firstChild);
  }

  // Estilizar container de erros
  errorContainer.style.backgroundColor = "#fee2e2";
  errorContainer.style.border = "1px solid #fca5a5";
  errorContainer.style.borderRadius = "8px";
  errorContainer.style.padding = "1rem";
  errorContainer.style.marginBottom = "1rem";
  errorContainer.style.color = "#dc2626";

  // Adicionar erros
  errorContainer.innerHTML = `
        <h4 style="margin: 0 0 0.5rem 0; color: #dc2626;">Por favor corrija os seguintes erros:</h4>
        <ul style="margin: 0; padding-left: 1.25rem;">
            ${errors.map((error) => `<li>${error}</li>`).join("")}
        </ul>
    `;

  // Scroll para o topo do formulário
  errorContainer.scrollIntoView({ behavior: "smooth", block: "center" });
}

/**
 * Processa o envio do formulário após validação
 * @param {Object} formData - Dados do formulário validados
 */
function processFormSubmission(formData) {
  // Remover erros anteriores
  const errorContainer = document.querySelector(".form-errors");
  if (errorContainer) {
    errorContainer.remove();
  }

  // Mostrar indicador de carregamento
  const submitButton = document.querySelector(".form-submit");
  const originalText = submitButton.textContent;
  submitButton.textContent = "Enviando...";
  submitButton.disabled = true;

  // Simular envio (em implementação real, aqui faria a requisição para o servidor)
  setTimeout(() => {
    // Mostrar mensagem de sucesso
    showSuccessMessage();

    // Limpar formulário
    document.getElementById("contact-form").reset();

    // Restaurar botão
    submitButton.textContent = originalText;
    submitButton.disabled = false;
  }, 2000);

  console.log("Dados do formulário:", formData);
}

/**
 * Mostra mensagem de sucesso após envio do formulário
 */
function showSuccessMessage() {
  const form = document.getElementById("contact-form");

  // Criar elemento de sucesso
  const successElement = document.createElement("div");
  successElement.className = "form-success";
  successElement.style.backgroundColor = "#dcfce7";
  successElement.style.border = "1px solid #86efac";
  successElement.style.borderRadius = "8px";
  successElement.style.padding = "1rem";
  successElement.style.marginBottom = "1rem";
  successElement.style.color = "#166534";

  successElement.innerHTML = `
        <h4 style="margin: 0 0 0.5rem 0; color: #166534;">✅ Mensagem enviada com sucesso!</h4>
        <p style="margin: 0;">Obrigado pelo seu contacto. Responderemos em breve através do email fornecido.</p>
    `;

  // Inserir no início do formulário
  form.insertBefore(successElement, form.firstChild);

  // Scroll para a mensagem
  successElement.scrollIntoView({ behavior: "smooth", block: "center" });

  // Remover mensagem após 10 segundos
  setTimeout(() => {
    successElement.remove();
  }, 10000);
}

/* ===== ANIMAÇÕES E INTERAÇÕES ===== */

/**
 * Inicializa animações e micro-interações
 * Melhora a experiência visual do usuário
 */
function initAnimations() {
  // Animação de entrada para elementos quando aparecem na tela
  initScrollAnimations();

  // Efeitos hover aprimorados
  initHoverEffects();

  // Animações de carregamento
  initLoadingAnimations();
}

/**
 * Inicializa animações baseadas no scroll
 */
function initScrollAnimations() {
  // Verificar se Intersection Observer está disponível
  if (!("IntersectionObserver" in window)) {
    return; // Não executar se não suportado
  }

  // Criar observador para elementos que entram na tela
  const observerOptions = {
    threshold: 0.1,
    rootMargin: "0px 0px -50px 0px",
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("animate-in");
        observer.unobserve(entry.target); // Parar de observar após animar
      }
    });
  }, observerOptions);

  // Selecionar elementos para animar
  const animateElements = document.querySelectorAll(
    ".card, .benefit-item, .focus-item, .value-item, .step-item, .contact-card, .expectation-item"
  );

  // Adicionar estilos iniciais e observar elementos
  animateElements.forEach((element, index) => {
    // Definir estado inicial
    element.style.opacity = "0";
    element.style.transform = "translateY(30px)";
    element.style.transition = "opacity 0.6s ease, transform 0.6s ease";
    element.style.transitionDelay = `${index * 0.1}s`; // Animação escalonada

    // Começar a observar
    observer.observe(element);
  });

  // Adicionar estilos para estado animado
  const style = document.createElement("style");
  style.textContent = `
        .animate-in {
            opacity: 1 !important;
            transform: translateY(0) !important;
        }
    `;
  document.head.appendChild(style);
}

/**
 * Inicializa efeitos hover aprimorados
 */
function initHoverEffects() {
  // Efeito parallax suave para cards
  const cards = document.querySelectorAll(
    ".card, .contact-card, .benefit-item"
  );

  cards.forEach((card) => {
    card.addEventListener("mouseenter", function () {
      this.style.transform = "translateY(-8px) scale(1.02)";
      this.style.transition = "transform 0.3s ease";
    });

    card.addEventListener("mouseleave", function () {
      this.style.transform = "translateY(0) scale(1)";
    });
  });

  // Efeito ripple para botões
  const buttons = document.querySelectorAll(".btn");
  buttons.forEach((button) => {
    button.addEventListener("click", function (e) {
      createRippleEffect(this, e);
    });
  });
}

/**
 * Cria efeito ripple em botões
 * @param {HTMLElement} button - Botão clicado
 * @param {Event} event - Evento de clique
 */
function createRippleEffect(button, event) {
  const ripple = document.createElement("span");
  const rect = button.getBoundingClientRect();
  const size = Math.max(rect.width, rect.height);
  const x = event.clientX - rect.left - size / 2;
  const y = event.clientY - rect.top - size / 2;

  ripple.style.width = ripple.style.height = size + "px";
  ripple.style.left = x + "px";
  ripple.style.top = y + "px";
  ripple.style.position = "absolute";
  ripple.style.borderRadius = "50%";
  ripple.style.backgroundColor = "rgba(255, 255, 255, 0.4)";
  ripple.style.transform = "scale(0)";
  ripple.style.animation = "ripple 0.6s linear";
  ripple.style.pointerEvents = "none";

  // Garantir que o botão tenha position relative
  const originalPosition = getComputedStyle(button).position;
  if (originalPosition === "static") {
    button.style.position = "relative";
  }
  button.style.overflow = "hidden";

  button.appendChild(ripple);

  // Remover ripple após animação
  setTimeout(() => {
    ripple.remove();
  }, 600);
}

/**
 * Adiciona animações de carregamento da página
 */
function initLoadingAnimations() {
  // Animação do hero
  const hero = document.querySelector(".hero");
  if (hero) {
    hero.style.opacity = "0";
    hero.style.transform = "translateY(20px)";

    setTimeout(() => {
      hero.style.transition = "opacity 0.8s ease, transform 0.8s ease";
      hero.style.opacity = "1";
      hero.style.transform = "translateY(0)";
    }, 100);
  }

  // Animação da navegação
  const nav = document.querySelector(".nav");
  if (nav) {
    nav.style.opacity = "0";
    nav.style.transform = "translateY(-20px)";

    setTimeout(() => {
      nav.style.transition = "opacity 0.6s ease, transform 0.6s ease";
      nav.style.opacity = "1";
      nav.style.transform = "translateY(0)";
    }, 200);
  }
}

/* ===== UTILITÁRIOS GERAIS ===== */

/**
 * Inicializa utilitários e funcionalidades auxiliares
 */
function initUtilities() {
  // Destacar link ativo na navegação
  highlightActiveNavLink();

  // Melhorar acessibilidade
  improveAccessibility();

  // Adicionar funcionalidades de keyboard
  initKeyboardNavigation();

  // Debug mode (apenas em desenvolvimento)
  if (window.location.hostname === "localhost") {
    initDebugMode();
  }
}

/**
 * Destaca o link ativo na navegação baseado na página atual
 */
function highlightActiveNavLink() {
  const currentPage = window.location.pathname.split("/").pop() || "index.html";
  const navLinks = document.querySelectorAll(".nav-link");

  navLinks.forEach((link) => {
    const linkHref = link.getAttribute("href");

    // Remover classe active de todos os links primeiro
    link.classList.remove("active");

    // Adicionar active ao link correspondente
    if (
      linkHref === currentPage ||
      (currentPage === "" && linkHref === "index.html") ||
      (currentPage === "index.html" && linkHref === "index.html")
    ) {
      link.classList.add("active");
    }
  });
}

/**
 * Melhora a acessibilidade geral do site
 */
function improveAccessibility() {
  // Adicionar skip links para navegação por teclado
  addSkipLinks();

  // Melhorar labels de formulários
  improveFormLabels();

  // Adicionar atributos ARIA onde necessário
  addAriaAttributes();
}

/**
 * Adiciona links de salto para acessibilidade
 */
function addSkipLinks() {
  const skipLink = document.createElement("a");
  skipLink.href = "#main-content";
  skipLink.textContent = "Saltar para conteúdo principal";
  skipLink.className = "skip-link";

  // Estilizar skip link (visível apenas no foco)
  skipLink.style.position = "absolute";
  skipLink.style.top = "-100px";
  skipLink.style.left = "10px";
  skipLink.style.background = "var(--rotary-blue)";
  skipLink.style.color = "white";
  skipLink.style.padding = "10px";
  skipLink.style.borderRadius = "4px";
  skipLink.style.textDecoration = "none";
  skipLink.style.zIndex = "9999";
  skipLink.style.transition = "top 0.3s ease";

  skipLink.addEventListener("focus", function () {
    this.style.top = "10px";
  });

  skipLink.addEventListener("blur", function () {
    this.style.top = "-100px";
  });

  // Adicionar ao início do body
  document.body.insertBefore(skipLink, document.body.firstChild);

  // Adicionar ID ao main se não existir
  const main = document.querySelector("main");
  if (main && !main.id) {
    main.id = "main-content";
  }
}

/**
 * Melhora os labels dos formulários para acessibilidade
 */
function improveFormLabels() {
  const formInputs = document.querySelectorAll("input, textarea, select");

  formInputs.forEach((input) => {
    const label = document.querySelector(`label[for="${input.id}"]`);

    if (label && input.hasAttribute("required")) {
      // Adicionar indicador visual de campo obrigatório
      if (!label.querySelector(".required-indicator")) {
        const indicator = document.createElement("span");
        indicator.className = "required-indicator";
        indicator.textContent = " *";
        indicator.style.color = "#ef4444";
        indicator.setAttribute("aria-label", "campo obrigatório");
        label.appendChild(indicator);
      }
    }
  });
}

/**
 * Adiciona atributos ARIA para melhor acessibilidade
 */
function addAriaAttributes() {
  // Adicionar role e aria-label ao menu mobile
  const mobileMenu = document.getElementById("mobile-menu");
  if (mobileMenu) {
    mobileMenu.setAttribute("role", "button");
    mobileMenu.setAttribute("aria-label", "Abrir menu de navegação");
    mobileMenu.setAttribute("aria-expanded", "false");
  }

  // Adicionar role à navegação principal
  const nav = document.querySelector(".nav");
  if (nav) {
    nav.setAttribute("role", "navigation");
    nav.setAttribute("aria-label", "Navegação principal");
  }

  // Adicionar landmarks
  const main = document.querySelector("main");
  if (main) {
    main.setAttribute("role", "main");
  }

  const footer = document.querySelector(".footer");
  if (footer) {
    footer.setAttribute("role", "contentinfo");
  }
}

/**
 * Inicializa navegação por teclado
 */
function initKeyboardNavigation() {
  // Permitir navegação por teclado no menu mobile
  const mobileMenu = document.getElementById("mobile-menu");
  if (mobileMenu) {
    mobileMenu.addEventListener("keydown", function (e) {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        this.click();
      }
    });
  }

  // Melhorar navegação por tabs
  const focusableElements = document.querySelectorAll(
    'a, button, input, textarea, select, [tabindex]:not([tabindex="-1"])'
  );

  focusableElements.forEach((element) => {
    element.addEventListener("focus", function () {
      this.style.outline = "2px solid var(--rotary-gold)";
      this.style.outlineOffset = "2px";
    });

    element.addEventListener("blur", function () {
      this.style.outline = "";
      this.style.outlineOffset = "";
    });
  });
}

/**
 * Modo debug para desenvolvimento (apenas em localhost)
 */
function initDebugMode() {
  console.log("🔧 Modo debug ativo");

  // Adicionar indicador visual de debug
  const debugIndicator = document.createElement("div");
  debugIndicator.textContent = "DEBUG";
  debugIndicator.style.position = "fixed";
  debugIndicator.style.bottom = "10px";
  debugIndicator.style.right = "10px";
  debugIndicator.style.background = "#ef4444";
  debugIndicator.style.color = "white";
  debugIndicator.style.padding = "5px 10px";
  debugIndicator.style.borderRadius = "4px";
  debugIndicator.style.fontSize = "12px";
  debugIndicator.style.zIndex = "9999";
  debugIndicator.style.fontFamily = "monospace";

  document.body.appendChild(debugIndicator);

  // Log de eventos para debug
  ["click", "submit", "focus", "blur"].forEach((eventType) => {
    document.addEventListener(eventType, function (e) {
      console.log(`🎯 Evento ${eventType}:`, e.target);
    });
  });

  // Função global para testar funcionalidades
  window.testRotaryFunctions = function () {
    console.log("🧪 Testando funcionalidades...");

    // Testar menu mobile
    const mobileMenu = document.getElementById("mobile-menu");
    if (mobileMenu) {
      console.log("✅ Menu mobile encontrado");
      mobileMenu.click();
      setTimeout(() => mobileMenu.click(), 1000);
    }

    // Testar validação de formulário
    const form = document.getElementById("contact-form");
    if (form) {
      console.log("✅ Formulário encontrado");
    }

    console.log("🎉 Teste concluído!");
  };

  console.log(
    "💡 Digite testRotaryFunctions() no console para testar as funcionalidades"
  );
}

/* ===== ANIMAÇÕES CSS ADICIONAIS ===== */

// Adicionar keyframes para animações via JavaScript
const animationStyles = document.createElement("style");
animationStyles.textContent = `
    @keyframes ripple {
        to {
            transform: scale(4);
            opacity: 0;
        }
    }
    
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    .field-error {
        border-color: #ef4444 !important;
        box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1) !important;
    }
`;

document.head.appendChild(animationStyles);

/* ===== EXPORTAR FUNÇÕES PARA USO GLOBAL ===== */

// Tornar algumas funções disponíveis globalmente se necessário
window.RotaryClubFunctions = {
  validateEmail: isValidEmail,
  showSuccessMessage: showSuccessMessage,
  createRipple: createRippleEffect,
};

// Log final de carregamento
console.log("✅ JavaScript do Rotary Club da Guarda carregado com sucesso!");
console.log("🌟 Service Above Self - Dar de Si Antes de Pensar em Si");
