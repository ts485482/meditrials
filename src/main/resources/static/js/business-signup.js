document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("businessSignupForm");
  if (!form) {
    return;
  }

  const contextPath = form.dataset.contextPath || "";
  const email = document.getElementById("email");
  const password = document.getElementById("password");
  const passwordConfirm = document.getElementById("passwordConfirm");
  const memberName = document.getElementById("memberName");
  const memberPhone = document.getElementById("memberPhone");
  const orgName = document.getElementById("orgName");
  const orgType = document.getElementById("orgType");
  const businessRegNo = document.getElementById("businessRegNo");
  const orgPhone = document.getElementById("orgPhone");
  const emailCheckButton = document.getElementById("emailCheckButton");
  const emailCheckMessage = document.getElementById("emailCheckMessage");
  const businessRegCheckButton = document.getElementById("businessRegCheckButton");
  const businessRegCheckMessage = document.getElementById("businessRegCheckMessage");
  const signupError = document.getElementById("signupError");
  const serverErrorCode = document.getElementById("serverErrorCode");

  let checkedEmail = "";
  let checkedBusinessRegNo = "";

  const serverMessages = {
    EMAIL_REQUIRED: "이메일을 입력해주세요.",
    PASSWORD_REQUIRED: "비밀번호를 입력해주세요.",
    PASSWORD_CONFIRM_REQUIRED: "비밀번호 확인을 입력해주세요.",
    NAME_REQUIRED: "이름을 입력해주세요.",
    MEMBER_PHONE_REQUIRED: "연락처를 입력해주세요.",
    ORG_NAME_REQUIRED: "기관명을 입력해주세요.",
    ORG_TYPE_REQUIRED: "기관 유형을 선택해주세요.",
    BUSINESS_REG_NO_REQUIRED: "사업자등록번호를 입력해주세요.",
    ORG_PHONE_REQUIRED: "기관 연락처를 입력해주세요.",
    EMAIL_INVALID: "올바른 이메일 형식을 입력해주세요.",
    EMAIL_DUPLICATED: "이미 사용 중인 이메일입니다.",
    PASSWORD_INVALID: "비밀번호는 8자 이상이며 영문자와 특수문자를 각각 1자 이상 포함해야 합니다.",
    PASSWORD_MISMATCH: "비밀번호와 비밀번호 확인이 일치하지 않습니다.",
    ORG_TYPE_INVALID: "기관 유형을 다시 선택해주세요.",
    BUSINESS_REG_NO_DUPLICATED: "이미 등록된 사업자등록번호입니다.",
    SIGNUP_FAILED: "가입 신청 처리 중 오류가 발생했습니다. 다시 시도해주세요."
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
    MEMBER_PHONE_REQUIRED: memberPhone,
    ORG_NAME_REQUIRED: orgName,
    ORG_TYPE_REQUIRED: orgType,
    ORG_TYPE_INVALID: orgType,
    BUSINESS_REG_NO_REQUIRED: businessRegNo,
    BUSINESS_REG_NO_DUPLICATED: businessRegNo,
    ORG_PHONE_REQUIRED: orgPhone
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
    if (target && typeof target.focus === "function") {
      target.focus();
    }
  };

  const hidePageError = () => {
    signupError.textContent = "";
    signupError.style.display = "none";
  };

  const showFieldMessage = (element, message, success) => {
    element.textContent = message;
    element.classList.toggle("is-success", success);
    element.classList.toggle("is-error", !success);
  };

  const resetFieldMessage = (element) => {
    element.textContent = "";
    element.classList.remove("is-success", "is-error");
  };

  const updatePasswordConfirmState = () => {
    const mismatch = passwordConfirm.value.length > 0
      && password.value !== passwordConfirm.value;
    passwordConfirm.classList.toggle("is-invalid", mismatch);
    passwordConfirm.setAttribute("aria-invalid", String(mismatch));
  };

  if (serverErrorCode && serverMessages[serverErrorCode.value]) {
    showPageError(
      serverMessages[serverErrorCode.value],
      errorTargets[serverErrorCode.value]
    );
  }

  email.addEventListener("input", () => {
    checkedEmail = "";
    resetFieldMessage(emailCheckMessage);
  });

  businessRegNo.addEventListener("input", () => {
    checkedBusinessRegNo = "";
    resetFieldMessage(businessRegCheckMessage);
  });

  password.addEventListener("input", updatePasswordConfirmState);
  passwordConfirm.addEventListener("input", updatePasswordConfirmState);

  emailCheckButton.addEventListener("click", async () => {
    hidePageError();
    const value = email.value.trim();

    if (!value) {
      showFieldMessage(emailCheckMessage, "이메일을 입력해주세요.", false);
      email.focus();
      return;
    }
    if (!email.checkValidity()) {
      showFieldMessage(emailCheckMessage, "올바른 이메일 형식을 입력해주세요.", false);
      email.focus();
      return;
    }

    emailCheckButton.disabled = true;
    try {
      const response = await fetch(
        `${contextPath}/member/check-email?email=${encodeURIComponent(value)}`,
        { headers: { Accept: "application/json" } }
      );
      if (!response.ok) {
        throw new Error("EMAIL_CHECK_FAILED");
      }
      const result = await response.json();
      showFieldMessage(emailCheckMessage, result.message, result.available);
      checkedEmail = result.available ? value : "";
    } catch (error) {
      checkedEmail = "";
      showFieldMessage(emailCheckMessage, "이메일 중복 확인 중 오류가 발생했습니다.", false);
    } finally {
      emailCheckButton.disabled = false;
    }
  });

  businessRegCheckButton.addEventListener("click", async () => {
    hidePageError();
    const value = businessRegNo.value.trim();

    if (!value) {
      showFieldMessage(businessRegCheckMessage, "사업자등록번호를 입력해주세요.", false);
      businessRegNo.focus();
      return;
    }

    businessRegCheckButton.disabled = true;
    try {
      const response = await fetch(
        `${contextPath}/business/check-registration-no?businessRegNo=${encodeURIComponent(value)}`,
        { headers: { Accept: "application/json" } }
      );
      if (!response.ok) {
        throw new Error("BUSINESS_REG_CHECK_FAILED");
      }
      const result = await response.json();
      showFieldMessage(businessRegCheckMessage, result.message, result.available);
      checkedBusinessRegNo = result.available ? value : "";
    } catch (error) {
      checkedBusinessRegNo = "";
      showFieldMessage(businessRegCheckMessage, "사업자등록번호 중복 확인 중 오류가 발생했습니다.", false);
    } finally {
      businessRegCheckButton.disabled = false;
    }
  });

  form.addEventListener("submit", (event) => {
    hidePageError();

    const requiredFields = [
      { element: email, message: "이메일을 입력해주세요.", trim: true },
      { element: password, message: "비밀번호를 입력해주세요.", trim: false },
      { element: passwordConfirm, message: "비밀번호 확인을 입력해주세요.", trim: false },
      { element: memberName, message: "이름을 입력해주세요.", trim: true },
      { element: memberPhone, message: "연락처를 입력해주세요.", trim: true },
      { element: orgName, message: "기관명을 입력해주세요.", trim: true },
      { element: orgType, message: "기관 유형을 선택해주세요.", trim: true },
      { element: businessRegNo, message: "사업자등록번호를 입력해주세요.", trim: true },
      { element: orgPhone, message: "기관 연락처를 입력해주세요.", trim: true }
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
      showPageError("비밀번호와 비밀번호 확인이 일치하지 않습니다.", passwordConfirm);
      return;
    }

    if (checkedBusinessRegNo !== businessRegNo.value.trim()) {
      event.preventDefault();
      showPageError("사업자등록번호 중복 확인을 먼저 진행해주세요.", businessRegCheckButton);
    }
  });
});
