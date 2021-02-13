pipeline {
    agent {label 'ios'}
	environment {
		PATH = "/usr/local/bin:$HOME/.rbenv/bin:$PATH"
	}
    stages {
        stage ('Initialize') {
            steps {
				sh '''
				eval "$(rbenv init -)"
				rbenv shell 2.7.2
                bundle config set --local path './vendor/bundle'
				bundle install
				'''
            }
        }

        stage ('Test') {
            steps {
				sh "xcodebuild -scheme chipscanlib-swift -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' test -resultBundlePath ./tests.xcresult"
				sh '''
					bundle config set --local path './vendor/bundle'
					bundle exec trainer
					'''
            }
            post {
                always {
                    junit './*.xml'
                }
            }
        }
		

	
    }
}