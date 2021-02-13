pipeline {
    agent {label 'ios'}
    stages {
        stage ('Initialize') {
            steps {
				sh 'rbenv init'
				sh 'rbenv local 2.7.2'
                sh 'bundle install --path=./vendor/bundle'
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