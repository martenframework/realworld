import initFavoriteButtons from '../../core/initFavoriteButtons';
import initFollowButtons from '../../core/initFollowButtons';

export default {
  async init() {
    const articlePageDiv = document.getElementById('article_page');
    await initFollowButtons(articlePageDiv.dataset.authorUsername);
    await initFavoriteButtons();
  },
};
