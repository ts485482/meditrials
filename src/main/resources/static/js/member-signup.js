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
    REQUIRED: "모든 필수 항목을 입력해주세요.",
    EMAIL_INVALID: "올바른 이메일 형식을 입력해주세요.",
    EMAIL_DUPLICATED: "이미 사용 중인 이메일입니다.",
    PASSWORD_MISMATCH: "비밀번호와 비밀번호 확인이 일치하지 않습니다."
  };

  const showPageError = (message) => {
    signupError.textContent = message;
    signupError.style.display = "block";
  };

  const hidePageError = () => {
    signupError.textContent = "";
    signupError.style.display = "none";
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
    showPageError(serverMessages[serverErrorCode.value]);
  }

  email.addEventListener("input", resetEmailCheck);

  emailCheckButton.addEventListener("click", async () => {
    hidePageError();
    const emailValue = email.value.trim();

    if (!emailValue || !email.checkValidity()) {
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

    if (!email.value.trim() || !password.value || !passwordConfirm.value
        || !memberName.value.trim() || !phone.value.trim()) {
      event.preventDefault();
      showPageError("모든 필수 항목을 입력해주세요.");
      return;
    }

    if (!email.checkValidity()) {
      event.preventDefault();
      showPageError("올바른 이메일 형식을 입력해주세요.");
      email.focus();
      return;
    }

    if (checkedEmail !== email.value.trim()) {
      event.preventDefault();
      showPageError("이메일 중복 확인을 먼저 진행해주세요.");
      emailCheckButton.focus();
      return;
    }

    if (password.value !== passwordConfirm.value) {
      event.preventDefault();
      showPageError("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
      passwordConfirm.focus();
    }
  });
});
