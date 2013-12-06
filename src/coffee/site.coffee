$ = jQuery 

# api

api_root = '/w/socialpoetry'

# will init sammy app into this later
app = null

# main controllers 
window.actions =

	displaySection : (section) ->

		$('.container').hide()
		$('#' + section).show()

	doSearch : (hashtag) ->

		$('#search-results').html('<p>... loading ...</p>')

		$.ajax {
			url : api_root + '/api/search',
			type : 'get',
			data : {'hashtag' : hashtag},
			dataType : 'json',
			success : (data) ->

				html = ''

				for status in data

					html+= '<div class = "result"><p><em>' + status.id + '</em><span>' + status.text + '</span></p></div>'

				$('#search-results').html(html)

				$('#search-results .result').click () ->

					$(@).addClass 'selected'

		}

	doList : (hashtag) ->

		$('#list-results').html('<p>... loading ...</p>')

		$.ajax {
			url : api_root + '/api/list',
			type : 'get',
			data : {'hashtag' : hashtag},
			dataType : 'json',
			success : (data) ->

				html = ''

				for hashtag, ids of data

					for id in ids

						html+= '<div class = "result" data-hashtag = "' + hashtag + '" data-id = "' + id + '"><p><span>#' + hashtag + ' : ' + id + '</span></p></div>'

				$('#list-results').html(html)

				$('#list-results .result').click () ->

					window.location = '#/view/' + $(@).attr('data-hashtag') + '/' + $(@).attr('data-id')


		}

	doView : (hashtag, id) ->

		$.ajax {
			url : api_root + '/api/poem/' + hashtag + '/' + id,
			type : 'get',
			data : {},
			dataType : 'json',
			success : (data) ->

				$('#view-title').html '#' + hashtag
				$('#view-poem').html data.poem
		}

	doWrite : () ->

		poemContent = []

		console.log "doing write"

		$('#search-results .result.selected').each () ->

			console.log "found selected tweet"
			poemContent.push $('span', @).html()

		$('#write-poem').val poemContent.join("\n")

	doSave : () ->



		$.ajax {

			url : api_root + '/api/poem/' + $('#write-hashtag').val(),
			type : 'post',
			data : {poem : $('#write-poem').val()},
			dataType : 'json',
			success : (data) ->

				window.location = '#/view/' + data.hashtag + '/' + data.id

		}


# ---

# --- SAMMY INITIALIZATIOn

app = $.sammy () ->

	@.get '#/', (context) ->

		actions.displaySection 'introduction'

	@.get '#/search', (context) ->

		actions.displaySection 'search'

		$('#search_hashtag').focus()

	@.get '#/list', (context) ->

		actions.doList('')

		actions.displaySection 'list'

	@.get '#/write/:hashtag', (context) ->

		$('#write-hashtag').val @params.hashtag

		actions.doWrite()

		actions.displaySection 'write'

	@.get '#/view/:hashtag/:id', (context) ->

		actions.doView @params.hashtag, @params.id

		actions.displaySection 'view'

#---

$(document).ready () ->

	actions.doList ''

	app.run('#/')



		