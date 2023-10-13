import axios from 'axios';

import getCSRFToken from './getCSRFToken';

export default async function initFollowButtons(username) {
  const followButtons = document.querySelectorAll('.follow-button');
  const followTexts = document.querySelectorAll('.follow-text');
  const unfollowTexts = document.querySelectorAll('.unfollow-text');

  if (followButtons.length > 0) {
    const csrfToken = getCSRFToken();
    followButtons.forEach((followButton) => {
      followButton.addEventListener('click', async () => {
        const response = await axios.post(
          `/@${username}/follow`,
          {},
          { headers: { 'X-CSRF-Token': csrfToken } },
        );
        if (response.data.following) {
          followTexts.forEach((followText) => {
            followText.style.display = 'none';
          });
          unfollowTexts.forEach((unfollowText) => {
            unfollowText.style.display = 'inline';
          });
        } else {
          followTexts.forEach((followText) => {
            followText.style.display = 'inline';
          });
          unfollowTexts.forEach((unfollowText) => {
            unfollowText.style.display = 'none';
          });
        }
      });
    });
  }
}
