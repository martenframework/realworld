import axios from 'axios';

import getCSRFToken from './getCSRFToken';

export default async function initFavoriteButtons() {
  const favoriteButtons = document.querySelectorAll('.favorite-button');

  if (favoriteButtons.length > 0) {
    const csrfToken = getCSRFToken();
    favoriteButtons.forEach((favoriteButton) => {
      const slug = favoriteButton.dataset.articleSlug;
      favoriteButton.addEventListener('click', async () => {
        const response = await axios.post(
          `/article/${slug}/favorite`,
          {},
          { headers: { 'X-CSRF-Token': csrfToken } },
        );

        favoriteButtons.forEach((b) => {
          if (b.dataset.articleSlug === slug) {
            b.classList.toggle('btn-outline-primary');
            b.classList.toggle('btn-primary');
            const counter = b.querySelector('.counter');

            if (response.data.favorited) {
              counter.textContent = parseInt(counter.textContent, 10) + 1;
            } else {
              counter.textContent = parseInt(counter.textContent, 10) - 1;
            }
          }
        });
      });
    });
  }
}
