document.addEventListener('DOMContentLoaded', function() {
    const typedTextSpan = document.querySelector(".typed-text");

    const titles = [
        "Cloud Engineer",
        "Full Stack Developer",
        "Critical Thinker",
        "Problem Solver"
    ];

    let currentTitleIndex = 0;
    let currentCharIndex = 0;
    let isDeleting = false;
    let typingDelay = 100;
    let erasingDelay = 50;
    let newTitleDelay = 2000;

    function type() {
        const currentTitle = titles[currentTitleIndex];
        
        if (isDeleting) {
            typedTextSpan.textContent = currentTitle.substring(0, currentCharIndex - 1);
            currentCharIndex--;
        } else {
            typedTextSpan.textContent = currentTitle.substring(0, currentCharIndex + 1);
            currentCharIndex++;
        }

        let delay = isDeleting ? erasingDelay : typingDelay;
        
        if (!isDeleting && currentCharIndex === currentTitle.length) {
            delay = newTitleDelay;
            isDeleting = true;
        } else if (isDeleting && currentCharIndex === 0) {
            isDeleting = false;
            currentTitleIndex = (currentTitleIndex + 1) % titles.length;
        }
        
        setTimeout(type, delay);
    }

    // Start the typing animation
    type();
}); 