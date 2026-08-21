
document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-tab]").forEach(tab => {
    tab.addEventListener("click", () => {
      const group = tab.parentElement;
      group.querySelectorAll("[data-tab]").forEach(x => x.classList.remove("active"));
      tab.classList.add("active");
    });
  });

  document.querySelectorAll("[data-demo-alert]").forEach(btn => {
    btn.addEventListener("click", () => {
      alert(btn.dataset.demoAlert || "화면 목업 단계의 데모 버튼입니다.");
    });
  });
});
