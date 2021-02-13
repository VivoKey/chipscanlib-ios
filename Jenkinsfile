pipeline {
    agent {label 'ios'}
	environment {
		PATH = "/usr/local/bin:$HOME/.rbenv/bin:$PATH"
	}
    stages {
        stage ('Initialize') {
            steps {
				sh 'rbenv init -'
				sh 'gem install bundle'
                sh 'bundle install'
            }
        }

        stage ('Test') {
            steps {
				sh "xcodebuild -scheme chipscanlib-swift -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' test -resultBundlePath ./tests.xcresult"
				sh "trainer"
            }
            post {
                always {
                    junit './*.xml'
                }
            }
        }
		

	
    }
}