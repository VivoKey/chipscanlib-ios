pipeline {
    agent {label 'ios'}
	environment {
		PATH = "/usr/local/bin:$HOME/.rbenv/bin:$PATH"
	}
    stages {
        stage ('Initialize') {
            steps {
				sh 'rbenv init -'
				sh 'rbenv local 2.7.2'
                sh "bundle config set --local path './vendor/bundle'"
				sh 'bundle install'
            }
        }

        stage ('Test') {
            steps {
				sh "xcodebuild -scheme chipscanlib-swift -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' test -resultBundlePath ./tests.xcresult"
				sh "bundle exec trainer"
            }
            post {
                always {
                    junit './*.xml'
                }
            }
        }
		

	
    }
}