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
					rm -rf ./tests.xcresult
				'''
            }
        }

        stage ('Test') {
            steps {
				sh "xcodebuild -scheme chipscanlibswift -resultBundlePath ./tests.xcresult -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' clean test"
				sh '''
					eval "$(rbenv init -)"
					rbenv shell 2.7.2
					bundle config set --local path './vendor/bundle'
					bundle install
					bundle exec trainer
					'''
            }
            post {
                always {
                    junit 'tests.xml'
                }
            }
        }
		

	
    }
}