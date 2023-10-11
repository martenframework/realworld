import initFollowButton from '../../core/initFollowButton';

export default {
  async init() {
    const articlePageDiv = document.getElementById('article_page');
    await initFollowButton(articlePageDiv.dataset.authorUsername);
  },
};
