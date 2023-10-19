import initFavoriteButtons from '../../core/initFavoriteButtons';
import initFollowButtons from '../../core/initFollowButtons';

export default {
  async init() {
    const profilePageDiv = document.getElementById('profile_page');
    await initFollowButtons(profilePageDiv.dataset.username);
    await initFavoriteButtons();
  },
};
