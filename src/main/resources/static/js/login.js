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

    emailInput.addEventListener("input", () => {
        clearFieldError(emailInput, emailError);
        loginMessage.textContent = "";
    });

    passwordInput.addEventListener("input", () => {
        clearFieldError(passwordInput, passwordError);
        loginMessage.textContent = "";
    });

    form.addEventListener("submit", (event) => {
        event.preventDefault();

        const email = emailInput.value.trim();
        const password = passwordInput.value;
        let valid = true;

        clearFieldError(emailInput, emailError);
        clearFieldError(passwordInput, passwordError);
        loginMessage.textContent = "";

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
            const firstInvalid = form.querySelector(".is-invalid");
            if (firstInvalid) {
                firstInvalid.focus();
            }
            return;
        }

        /*
         * MEMBER DB와 인증 기능을 연결하기 전까지는 실제 로그인 요청을 보내지 않는다.
         * 추후 Spring Security 적용 시 이 부분을 제거하고 form action으로 인증 요청한다.
         */
        loginMessage.textContent = "로그인 화면 검증이 완료되었습니다. 실제 인증은 회원 기능 연결 단계에서 적용됩니다.";
    });
})();
