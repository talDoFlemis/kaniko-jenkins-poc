pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:debug
      command:
        - /busybox/cat
      tty: true
      volumeMounts:
        - name: kaniko-secret
          mountPath: /kaniko/.docker
  restartPolicy: Never
  volumes:
    - name: kaniko-secret
      secret:
        secretName: jenkins-harbor-service-account
        items:
          - key: .dockerconfigjson
            path: config.json
        '''
        }
    }
    stages {
        stage('Release') {
            steps {
                container('kaniko') {
                    sh '/kaniko/executor --context . --dockerfile ./echo-server/Dockerfile --destination ttl.sh/golang-echo-server:1h'
                }
            }
        }
    }
}
