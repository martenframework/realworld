import ArticleCreateUpdateController from './blogging/ArticleCreateUpdateController';
import ArticleDetailController from './blogging/ArticleDetailController';
import ProfileDetailController from './profiles/ProfileDetailController';

// Defines the controllers object.
export default {
  'blogging:article_create_update': ArticleCreateUpdateController,
  'blogging:article_detail': ArticleDetailController,
  'profiles:profile_detail': ProfileDetailController,
};
