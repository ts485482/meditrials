(() => {
    "use strict";

    const form = document.getElementById("loginForm");
    if (!form) {
        return;
    }

    const emailInput = document.getElementById("email");
    const passwordInput = document.getElementById("password");
    const emailError = document.getElementById("emailError");
    const passwordError = document.getElementById("passwordError");
    const loginMessage = document.getElementById("loginMessage");

    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    function clearFieldError(input, errorElement) {
        input.classList.remove("is-invalid");
        errorElement.textContent = "";
    }

    function setFieldError(input, errorElement, message) {
        input.classList.add("is-invalid");
        errorElement.textContent = message;
    }

    function clearLoginMessage() {
        loginMessage.textContent = "";
    }

    function applyServerError() {
        const errorCode = form.dataset.errorCode || "";

        if (errorCode === "LOGIN_REQUIRED") {
            loginMessage.textContent = "이메일과 비밀번호를 모두 입력해주세요.";
            return;
        }

        if (errorCode === "EMAIL_INVALID") {
            setFieldError(emailInput, emailError, "이메일 형식이 올바르지 않습니다.");
            return;
        }

        if (errorCode === "AUTH_FAILED") {
            emailInput.classList.add("is-invalid");
            passwordInput.classList.add("is-invalid");
            loginMessage.textContent = "이메일 또는 비밀번호가 일치하지 않습니다.";
            return;
        }

        if (errorCode === "ACCOUNT_INACTIVE") {
            loginMessage.textContent = "현재 이용할 수 없는 계정입니다. 관리자에게 문의해주세요.";
        }
    }

    emailInput.addEventListener("input", () => {
        clearFieldError(emailInput, emailError);
        clearLoginMessage();
    });

    passwordInput.addEventListener("input", () => {
        clearFieldError(passwordInput, passwordError);
        emailInput.classList.remove("is-invalid");
        clearLoginMessage();
    });

    form.addEventListener("submit", (event) => {
        const email = emailInput.value.trim();
        const password = passwordInput.value;
        let valid = true;

        clearFieldError(emailInput, emailError);
        clearFieldError(passwordInput, passwordError);
        clearLoginMessage();

        if (!email) {
            setFieldError(emailInput, emailError, "이메일을 입력해주세요.");
            valid = false;
        } else if (!emailPattern.test(email)) {
            setFieldError(emailInput, emailError, "이메일 형식이 올바르지 않습니다.");
            valid = false;
        }

        if (!password) {
            setFieldError(passwordInput, passwordError, "비밀번호를 입력해주세요.");
            valid = false;
        }

        if (!valid) {
            event.preventDefault();
            const firstInvalid = form.querySelector(".is-invalid");
            if (firstInvalid) {
                firstInvalid.focus();
            }
        }
    });

    applyServerError();
})();
