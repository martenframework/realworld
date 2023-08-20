export default {
  async init() {
    const tagsFakeInput = document.getElementById('tags_fake_input');
    const tagsList = document.getElementById('tags_list');

    const setupRemoveButtons = () => {
      const removeButtons = document.querySelectorAll('.tag-default.tag-pill i');
      removeButtons.forEach((button) => {
        button.addEventListener('click', (e) => {
          const tag = e.target.parentNode.textContent;
          const tagsInput = document.getElementById('tags_real_input');
          const tags = tagsInput.value.split(',');
          tags.splice(tags.indexOf(tag), 1);
          tagsInput.value = tags.filter((t) => t.length > 0).join(',');
          e.target.parentNode.remove();
        });
      });
    };

    const renderTags = (tags) => {
      const tagsInput = document.getElementById('tags_real_input');

      tagsInput.value = tags.filter((t) => t.length > 0).join(',');
      tagsFakeInput.value = '';

      tagsList.innerHTML = '';
      tags.forEach((t) => {
        const tagEl = document.createElement('span');
        tagEl.className = 'tag-default tag-pill';

        const tagRemove = document.createElement('i');
        tagRemove.className = 'ion-close-round';
        tagEl.appendChild(tagRemove);

        const textNode = document.createTextNode(t);
        tagEl.appendChild(textNode);

        tagsList.appendChild(tagEl);
      });

      setupRemoveButtons();
    };

    const insertTag = (tag) => {
      const tagsInput = document.getElementById('tags_real_input');
      const tags = tagsInput.value.split(',').filter((t) => t.length > 0);

      tags.push(tag);

      renderTags(tags);
    };

    tagsFakeInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ',') {
        e.preventDefault();
        insertTag(e.target.value);
      }
    });

    const setupTags = () => {
      const tagsInput = document.getElementById('tags_real_input');
      const tags = tagsInput.value.split(',').filter((t) => t.length > 0);
      renderTags(tags);
    };

    setupTags();
  },
};
