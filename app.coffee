express = require "express"
Twit = require "twit"

fs = require "fs"
crypto = require "crypto"

config = require "./config"

T = new Twit({
    consumer_key:         config.consumer_key
  , consumer_secret:      config.consumer_secret
  , access_token:         config.access_token
  , access_token_secret:  config.access_token_secret
})

app = new express()

# middleware
app.use(express.bodyParser());
# serve static content
app.use(express.static(__dirname + '/static'));

# API methods (get tweets)

app.get '/api/search', (req, res) ->

	hashtag = req.query.hashtag

	parseExpressions = []

	parseExpressions.push /@([a-zA-Z1234567890_]+)/g
	parseExpressions.push /((mailto\:|(news|(ht|f)tp(s?))\:\/\/){1}\S+)/g

	if(hashtag == undefined)

		res.send
			status : 'ERROR'
			message : 'Hashtag undefined!'

	else

		T.get 'search/tweets', { q : '#' + hashtag, lang : 'en', count : 100 }, (err, reply) ->

			parsed = []

			for status in reply.statuses

				parsedText = status.text

				for ex in parseExpressions
					parsedText = parsedText.replace ex, ''

				parsed.push {'id' : status.id, 'text' : parsedText}

			res.send parsed

app.get '/api/list', (req, res) ->

	hashtag = req.query.hashtag
	hashtagEx = eval('/(.*)' + hashtag + '(.*)/')

	files = fs.readdirSync config.db_dir

	list = {}

	for f in files

		tokens = f.split('_')

		nameTokens = tokens[1].split('.')
		nameTokens = nameTokens[0]
		

		if(hashtag != undefined && hashtag != '')

			

			if(hashtagEx.test(nameTokens))
				if(list[nameTokens] == undefined)
					list[nameTokens] = []
				list[nameTokens].push tokens[0]

		else
			if(list[nameTokens] == undefined)
				list[nameTokens] = []
			list[nameTokens].push tokens[0]

	res.send list

app.get '/api/poem/:hashtag/:id', (req, res) ->

	content = fs.readFileSync config.db_dir + '/' + req.params.id + '_' + req.params.hashtag + '.txt', 'utf8'

	res.send
		poem : content

app.post '/api/poem/:hashtag', (req, res) ->

	md5sum = crypto.createHash 'md5'
	md5sum.update req.ip + req.params.hashtag + new Date().getTime()
	poemId = md5sum.digest 'hex'

	fs.writeFileSync config.db_dir + '/' + poemId + '_' + req.params.hashtag + '.txt', req.body.poem

	res.send
		id : poemId
		'hashtag' : req.params.hashtag

# --- RUN IT

app.listen config.port
console.log "Application started at port " + config.port