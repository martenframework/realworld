import initFollowButton from '../../core/initFollowButton';

export default {
  async init() {
    const profilePageDiv = document.getElementById('profile_page');
    await initFollowButton(profilePageDiv.dataset.username);
  },
};
