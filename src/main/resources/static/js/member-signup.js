document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("memberSignupForm");
  if (!form) {
    return;
  }

  const contextPath = form.dataset.contextPath || "";
  const email = document.getElementById("email");
  const password = document.getElementById("password");
  const passwordConfirm = document.getElementById("passwordConfirm");
  const memberName = document.getElementById("memberName");
  const phone = document.getElementById("phone");
  const emailCheckButton = document.getElementById("emailCheckButton");
  const emailCheckMessage = document.getElementById("emailCheckMessage");
  const signupError = document.getElementById("signupError");
  const serverErrorCode = document.getElementById("serverErrorCode");

  let checkedEmail = "";

  const serverMessages = {
    EMAIL_REQUIRED: "이메일을 입력해주세요.",
    PASSWORD_REQUIRED: "비밀번호를 입력해주세요.",
    PASSWORD_CONFIRM_REQUIRED: "비밀번호 확인을 입력해주세요.",
    NAME_REQUIRED: "이름을 입력해주세요.",
    PHONE_REQUIRED: "연락처를 입력해주세요.",
    EMAIL_INVALID: "올바른 이메일 형식을 입력해주세요.",
    EMAIL_DUPLICATED: "이미 사용 중인 이메일입니다.",
    PASSWORD_INVALID: "비밀번호는 8자 이상이며 영문자와 특수문자를 각각 1자 이상 포함해야 합니다.",
    PASSWORD_MISMATCH: "비밀번호와 비밀번호 확인이 일치하지 않습니다."
  };

  const errorTargets = {
    EMAIL_REQUIRED: email,
    EMAIL_INVALID: email,
    EMAIL_DUPLICATED: email,
    PASSWORD_REQUIRED: password,
    PASSWORD_INVALID: password,
    PASSWORD_CONFIRM_REQUIRED: passwordConfirm,
    PASSWORD_MISMATCH: passwordConfirm,
    NAME_REQUIRED: memberName,
    PHONE_REQUIRED: phone
  };

  const specialCharacters = "!@#$%^&*()_+-=[]{};:,.<>/?`~";

  const isValidPassword = (value) => {
    const hasEnglishLetter = /[A-Za-z]/.test(value);
    const hasSpecialCharacter = Array.from(value)
      .some((character) => specialCharacters.includes(character));

    return value.length >= 8 && hasEnglishLetter && hasSpecialCharacter;
  };

  const showPageError = (message, target) => {
    signupError.textContent = message;
    signupError.style.display = "block";
    if (target) {
      target.focus();
    }
  };

  const hidePageError = () => {
    signupError.textContent = "";
    signupError.style.display = "none";
  };

  const updatePasswordConfirmState = () => {
    const confirmValue = passwordConfirm.value;
    const isMismatch = confirmValue.length > 0 && password.value !== confirmValue;

    passwordConfirm.classList.toggle("is-invalid", isMismatch);
    passwordConfirm.setAttribute("aria-invalid", String(isMismatch));
  };

  const showEmailMessage = (message, success) => {
    emailCheckMessage.textContent = message;
    emailCheckMessage.classList.toggle("is-success", success);
    emailCheckMessage.classList.toggle("is-error", !success);
  };

  const resetEmailCheck = () => {
    checkedEmail = "";
    emailCheckMessage.textContent = "";
    emailCheckMessage.classList.remove("is-success", "is-error");
  };

  if (serverErrorCode && serverMessages[serverErrorCode.value]) {
    showPageError(
      serverMessages[serverErrorCode.value],
      errorTargets[serverErrorCode.value]
    );
  }

  email.addEventListener("input", resetEmailCheck);
  password.addEventListener("input", updatePasswordConfirmState);
  passwordConfirm.addEventListener("input", updatePasswordConfirmState);

  emailCheckButton.addEventListener("click", async () => {
    hidePageError();
    const emailValue = email.value.trim();

    if (!emailValue) {
      showEmailMessage("이메일을 입력해주세요.", false);
      email.focus();
      return;
    }

    if (!email.checkValidity()) {
      showEmailMessage("올바른 이메일 형식을 입력해주세요.", false);
      email.focus();
      return;
    }

    emailCheckButton.disabled = true;
    try {
      const response = await fetch(
        `${contextPath}/member/check-email?email=${encodeURIComponent(emailValue)}`,
        { headers: { Accept: "application/json" } }
      );

      if (!response.ok) {
        throw new Error("EMAIL_CHECK_FAILED");
      }

      const result = await response.json();
      showEmailMessage(result.message, result.available);
      checkedEmail = result.available ? emailValue : "";
    } catch (error) {
      checkedEmail = "";
      showEmailMessage("이메일 중복 확인 중 오류가 발생했습니다.", false);
    } finally {
      emailCheckButton.disabled = false;
    }
  });

  form.addEventListener("submit", (event) => {
    hidePageError();

    const requiredFields = [
      { element: email, message: "이메일을 입력해주세요.", trim: true },
      { element: password, message: "비밀번호를 입력해주세요.", trim: false },
      { element: passwordConfirm, message: "비밀번호 확인을 입력해주세요.", trim: false },
      { element: memberName, message: "이름을 입력해주세요.", trim: true },
      { element: phone, message: "연락처를 입력해주세요.", trim: true }
    ];

    const emptyField = requiredFields.find((field) => {
      const value = field.trim ? field.element.value.trim() : field.element.value;
      return !value;
    });

    if (emptyField) {
      event.preventDefault();
      showPageError(emptyField.message, emptyField.element);
      return;
    }

    if (!email.checkValidity()) {
      event.preventDefault();
      showPageError("올바른 이메일 형식을 입력해주세요.", email);
      return;
    }

    if (checkedEmail !== email.value.trim()) {
      event.preventDefault();
      showPageError("이메일 중복 확인을 먼저 진행해주세요.", emailCheckButton);
      return;
    }

    if (!isValidPassword(password.value)) {
      event.preventDefault();
      showPageError(
        "비밀번호는 8자 이상이며 영문자와 특수문자를 각각 1자 이상 포함해야 합니다.",
        password
      );
      return;
    }

    if (password.value !== passwordConfirm.value) {
      event.preventDefault();
      passwordConfirm.classList.add("is-invalid");
      passwordConfirm.setAttribute("aria-invalid", "true");
      showPageError("비밀번호와 비밀번호 확인이 일치하지 않습니다.", passwordConfirm);
      return;
    }

    passwordConfirm.classList.remove("is-invalid");
    passwordConfirm.setAttribute("aria-invalid", "false");
  });
});
