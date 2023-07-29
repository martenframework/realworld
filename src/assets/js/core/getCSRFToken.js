import Cookies from 'js-cookie';

export default function getCSRFToken() {
  return Cookies.get('csrftoken');
}
