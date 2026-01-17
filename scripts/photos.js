// Photo modal functionality
const photoModal = document.getElementById('photo-modal');
const photoModalImage = document.getElementById('photo-modal-image');
const photoModalClose = document.getElementById('photo-modal-close');
const photoModalPrev = document.getElementById('photo-modal-prev');
const photoModalNext = document.getElementById('photo-modal-next');
const photoItems = document.querySelectorAll('.photo-item');
let currentPhotoIndex = 0;

// Collect all photos from all collections into a flat array
const allPhotos = Array.from(photoItems);

// Open modal when clicking on a photo
photoItems.forEach((item, index) => {
    item.addEventListener('click', () => {
        currentPhotoIndex = index;
        openModal();
    });
});

// Open modal function
function openModal() {
    if (allPhotos[currentPhotoIndex]) {
        const img = allPhotos[currentPhotoIndex].querySelector('.photo-image');
        photoModalImage.src = img.src;
        photoModalImage.alt = img.alt;
        photoModal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
}

// Close modal
function closeModal() {
    photoModal.classList.remove('active');
    document.body.style.overflow = '';
}

// Close modal on close button click
if (photoModalClose) {
    photoModalClose.addEventListener('click', closeModal);
}

// Close modal on background click
photoModal.addEventListener('click', (e) => {
    if (e.target === photoModal) {
        closeModal();
    }
});

// Close modal on Escape key
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && photoModal.classList.contains('active')) {
        closeModal();
    }
});

// Navigate to previous photo
if (photoModalPrev) {
    photoModalPrev.addEventListener('click', (e) => {
        e.stopPropagation();
        currentPhotoIndex = (currentPhotoIndex - 1 + allPhotos.length) % allPhotos.length;
        openModal();
    });
}

// Navigate to next photo
if (photoModalNext) {
    photoModalNext.addEventListener('click', (e) => {
        e.stopPropagation();
        currentPhotoIndex = (currentPhotoIndex + 1) % allPhotos.length;
        openModal();
    });
}

// Keyboard navigation (arrow keys)
document.addEventListener('keydown', (e) => {
    if (photoModal.classList.contains('active')) {
        if (e.key === 'ArrowLeft') {
            currentPhotoIndex = (currentPhotoIndex - 1 + allPhotos.length) % allPhotos.length;
            openModal();
        } else if (e.key === 'ArrowRight') {
            currentPhotoIndex = (currentPhotoIndex + 1) % allPhotos.length;
            openModal();
        }
    }
});

// Lazy loading for images
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                if (img.dataset.src) {
                    img.src = img.dataset.src;
                    img.removeAttribute('data-src');
                }
                observer.unobserve(img);
            }
        });
    });

    document.querySelectorAll('.photo-image[data-src]').forEach(img => {
        imageObserver.observe(img);
    });
}
