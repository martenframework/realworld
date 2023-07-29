import axios from 'axios';

import getCSRFToken from '../../core/getCSRFToken';

export default {
  async init() {
    const profilePageDiv = document.getElementById('profile_page');
    const followButton = document.getElementById('follow_button');
    const followText = document.getElementById('follow_text');
    const unfollowText = document.getElementById('unfollow_text');

    if (followButton) {
      const csrfToken = getCSRFToken();
      console.log(csrfToken);
      followButton.addEventListener('click', async () => {
        let response = await axios.post(
          `/@${profilePageDiv.dataset.username}/follow`,
          {},
          { headers: { 'X-CSRF-Token': csrfToken } }
        );
        if (response.data.following) {
          followText.style.display = 'none';
          unfollowText.style.display = 'inline';
        } else {
          followText.style.display = 'inline';
          unfollowText.style.display = 'none';
        }
      });
    }
  },
};
