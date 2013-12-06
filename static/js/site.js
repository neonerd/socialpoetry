(function() {
  var $, api_root, app;

  $ = jQuery;

  api_root = '/w/socialpoetry';

  app = null;

  window.actions = {
    displaySection: function(section) {
      $('.container').hide();
      return $('#' + section).show();
    },
    doSearch: function(hashtag) {
      $('#search-results').html('<p>... loading ...</p>');
      return $.ajax({
        url: api_root + '/api/search',
        type: 'get',
        data: {
          'hashtag': hashtag
        },
        dataType: 'json',
        success: function(data) {
          var html, status, _i, _len;
          html = '';
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            status = data[_i];
            html += '<div class = "result"><p><em>' + status.id + '</em><span>' + status.text + '</span></p></div>';
          }
          $('#search-results').html(html);
          return $('#search-results .result').click(function() {
            return $(this).addClass('selected');
          });
        }
      });
    },
    doList: function(hashtag) {
      $('#list-results').html('<p>... loading ...</p>');
      return $.ajax({
        url: api_root + '/api/list',
        type: 'get',
        data: {
          'hashtag': hashtag
        },
        dataType: 'json',
        success: function(data) {
          var html, id, ids, _i, _len;
          html = '';
          for (hashtag in data) {
            ids = data[hashtag];
            for (_i = 0, _len = ids.length; _i < _len; _i++) {
              id = ids[_i];
              html += '<div class = "result" data-hashtag = "' + hashtag + '" data-id = "' + id + '"><p><span>#' + hashtag + ' : ' + id + '</span></p></div>';
            }
          }
          $('#list-results').html(html);
          return $('#list-results .result').click(function() {
            return window.location = '#/view/' + $(this).attr('data-hashtag') + '/' + $(this).attr('data-id');
          });
        }
      });
    },
    doView: function(hashtag, id) {
      return $.ajax({
        url: api_root + '/api/poem/' + hashtag + '/' + id,
        type: 'get',
        data: {},
        dataType: 'json',
        success: function(data) {
          $('#view-title').html('#' + hashtag);
          return $('#view-poem').html(data.poem);
        }
      });
    },
    doWrite: function() {
      var poemContent;
      poemContent = [];
      console.log("doing write");
      $('#search-results .result.selected').each(function() {
        console.log("found selected tweet");
        return poemContent.push($('span', this).html());
      });
      return $('#write-poem').val(poemContent.join("\n"));
    },
    doSave: function() {
      return $.ajax({
        url: api_root + '/api/poem/' + $('#write-hashtag').val(),
        type: 'post',
        data: {
          poem: $('#write-poem').val()
        },
        dataType: 'json',
        success: function(data) {
          return window.location = '#/view/' + data.hashtag + '/' + data.id;
        }
      });
    }
  };

  app = $.sammy(function() {
    this.get('#/', function(context) {
      return actions.displaySection('introduction');
    });
    this.get('#/search', function(context) {
      actions.displaySection('search');
      return $('#search_hashtag').focus();
    });
    this.get('#/list', function(context) {
      actions.doList('');
      return actions.displaySection('list');
    });
    this.get('#/write/:hashtag', function(context) {
      $('#write-hashtag').val(this.params.hashtag);
      actions.doWrite();
      return actions.displaySection('write');
    });
    return this.get('#/view/:hashtag/:id', function(context) {
      actions.doView(this.params.hashtag, this.params.id);
      return actions.displaySection('view');
    });
  });

  $(document).ready(function() {
    actions.doList('');
    return app.run('#/');
  });

}).call(this);
