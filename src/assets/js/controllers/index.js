import ArticleCreateUpdateController from './blogging/ArticleCreateUpdateController';
import ArticleDetailController from './blogging/ArticleDetailController';
import HomeController from './blogging/HomeController';
import ProfileDetailController from './profiles/ProfileDetailController';

// Defines the controllers object.
export default {
  'blogging:article_create_update': ArticleCreateUpdateController,
  'blogging:article_detail': ArticleDetailController,
  'blogging:home': HomeController,
  'profiles:profile_detail': ProfileDetailController,
};
