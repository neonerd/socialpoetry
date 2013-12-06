module.exports = (grunt) ->

	grunt.initConfig({

		watch : 

			coffeescript :
				files : ['src/coffee/**/*.coffee']
				tasks : ['coffee']
				options : 
					spawn : true
			less :
				files : ['src/less/**/*.less']
				tasks : ['less']
				options : 
					spawn : true

		coffee :
			dev :
				options :
					bare : false
					join : true					
				files :
					"static/js/site.js" : ['src/coffee/site.coffee']

		less :
			dev :
				files :
					'static/css/site-dev.css' : 'src/less/site.less'
			prod :
				files :
					'static/css/site-prod.css' : 'src/less/site.less'
				options :
					cleancss : true

		connect :

			dev :

				options :

					port : 9000
					hostname : "0.0.0.0"
					keepalive : true
					base : './static'
	

	});

	grunt.loadNpmTasks('grunt-contrib-less');
	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-contrib-connect');

	grunt.registerTask 'server', ['connect']