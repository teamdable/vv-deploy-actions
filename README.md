# vv-deploy-actions
vv-deploy-actions는 edge device에 소스 코드 배포와 프로세스 재시작하는 작업을 reusable workflow로 제공한다. \
⚠️ warning ⚠️ 해당 repository는 public으로 관리되므로, commit시 주의하도록 한다. 

## Contents
1. [Deploy Actions](#deploy-actions): 소스 코드 배포 작업을 제공
    1. Variables: deploy-actions 사용시 필요한 변수들
    2. Usage: deploy-actions 사용법
    3. Example: deploy-actions 사용 예시
2. [Restart Actions](#restart-actions): edge device에서의 프로세스 재시작 작업을 제공
    1. Variables: restart-actions 사용시 필요한 변수들
    2. Example: restart-actions 사용 예시
3. [Parallel Deployment](#parallel-deployment) (NEW)`: 배포장비를 입력받아 연속적으로 배포를 제공
    1. Variables:  Parallel Deployment 사용시 필요한 변수들
    2. Usage : Parallel Deployment 사용법
    3. Example : Parallel Deployment 사용 예시
-------------------------------
## deploy-actions
### Variables
배포하려는 소스코드의 repository에서 vv-deploy-actions의 reusable workflow를 활용할 때, 필요한 변수들에 대한 설명은 아래에서 확인한다.

#### Input variables
- `user` - edge device의 사용자 이름
- `code-name` - 배포하고자하는 코드 모듈 이름(배포 장비에서 사용되는 프로젝트 루트명을 따른다.) \
e.g. edge-player, process, resource
- `deploy-branch` - 배포하고자하는 코드 모듈의 배포 브랜치 \
- `parent-dir` - 배포 장비에서 모듈의 부모 경로 \
e.g. `/home/${user}`
- `version-file-name` - 배포하고자하는 모듈의 버전 파일 이름 \
e.g.  _version.py or .version
- `exclude-files-from-zip` - 소스코드 압축파일에서 제외한 파일들 이름 \
e.g. \_\_pycache\_\_/*
- `slack-channel` - deploy & install 스텝의 시작/완료 시 알람을 보낼 슬랙 채널

#### Secrets Variables
- `password` - edge device의 비밀번호
- `otp` - otp 생성기 설정번호

-------------------------------

### Usage
vv-deploy-actions의 reusable workflow를 활용할 때, 별도의 clone, install 작업은 필요하지 않다.

배포하려는 소스코드의 repository에서는 workflow파일에서 vv-deploy-actions의 reusable workflows를 호출한다. ( 아래의 1번, 2번 과정을 따른다. )

1. `bin/deploy/install-settings.sh`, `bin/deploy/vpn-config.ini` 파일들이 필요하다. 예시는 [example/](https://github.com/teamdable/vv-deploy-actions/blob/main/example/)에서 확인할 수 있다.

2. `.github/workflows/your-workflow-name.yml`를 작성한다. 예시는 아래에서 확인할 수 있다.
	``` yml
	name: Continuous Deploy
	on: push

	jobs:
	job-name:
	  uses: teamdable/vv-deploy-actions/.github/workflows/deploy-to-edge-devices.yml@main
	  with:
	    user: '$USERNAME'
	    code-name: '$CODE_NAME'
	    parent-dir: '$PARENT_DIR'
	    version-file-name: '$VERSION_FILE'
	    exclude-files-from-zip: '$EXCLUDE_FILE'
	    slack-channel: '$SLACK_CHANNEL'
	  secrets:
	    password: ${{ secrets.PASSWORD }}
	    otp: ${{ secrets.OTP }}
	```

	output: 
	<details>
	<summary>Build</summary>

	- Success
		```
		deleting: .github/
		deleting: .github/workflows/
		deleting: .github/workflows/main-cd.yml
		```
	</details>

	<details>
	<summary>Deploy & Install</summary>

	- All success: 모든 HOST에 성공적으로 배포되면, 정상적으로 종료됩니다.

		```
		hostname: 127.0.0.1
		build & deploy Success
		install Success

		hostname: 127.0.0.2
		build & deploy Success
		install Success

		hostname: 127.0.0.3
		build & deploy Success
		install Success

		Deploy와 Install에 모두 성공하였습니다
		```

	- Fail: 모든 HOST에 배포를 진행하고, 과정이 완료된 후에 하나라도 배포가 실패했을 시에 Actions가 실패합니다.

		```
		hostname: 127.0.0.2
		build & deploy Success
		[err] target version과 source version이 일치하지않습니다

		hostname: 127.0.0.3
		[err] 배포 대상 edge device에 deploy 작업이 제대로 이루어지지않았습니다

		Deploy와 Install에 실패한 기기들의 hostname은 다음과 습니다
		Deploy: 127.0.0.3
		Install: 127.0.0.2 127.0.0.3
		```
	</details>

-------------------------------

### Example
#### 1. 프로세스 모니터링 모듈을 배포대상 장비의 ~/monitoring/process로 배포
- 버전을 표기하는 메타데이터를 _version.py로 명시한다.
- 배포 압축 파일에서 복수개의 파일들을 제외한다.
```diff
uses: teamdable/vv-deploy-actions/.github/workflows/deploy-to-edge-devices.yml@main
with:
    user: 'ubuntu'
!   code-name: 'process'
!   deploy-branch: ${GITHUB_REF##*/}    
!   parent-dir: '/home/ubuntu/monitoring/'
!   version-file-name: '_version.py'
-   exclude-files-from-zip: 'bin/deploy/vpn-config.ini'
+   exclude-files-from-zip: 'bin/deploy/vpn-config.ini __pycache__/*'
!   slack-channel: 'general'
secrets:
    password: ${{ secrets.PASSWORD }}
    otp: ${{ secrets.OTP }}
```

#### 2. inference 모듈을 배포대상 장비의 ~/inference 위치에 배포
- 버전을 표기하는 메타데이터를 _version.py로 명시한다.
- 배포 압축 파일에서 추가로 제외하지않는다.

```diff
uses: teamdable/vv-deploy-actions/.github/workflows/deploy-to-edge-devices.yml@main
with:
    user: 'ubuntu'
!   code-name: 'inference'
!   deploy-branch: ${GITHUB_REF##*/} 
!   parent-dir: '/home/ubuntu/'
!   version-file-name: '_version.py'
-   exclude-files-from-zip: 'bin/deploy/vpn-config.ini'
+   
!   slack-channel: 'general'
secrets:
    password: ${{ secrets.PASSWORD }}
    otp: ${{ secrets.OTP }}
```

-------------------------------
## restart-actions
### Variables
배포하려는 소스코드의 repository에서 vv-deploy-actions의 reusable workflow를 활용할 때, 필요한 변수들에 대한 설명은 아래에서 확인한다.

#### Input variables
- `user` - edge device의 사용자 이름
- `process-name` - 실행하고자하는 프로세스 이름 \
e.g. inference, edge-player, process-monitoring, resource-monitoring
- `slack-channel` - 프로세스 재시작 스텝 완료 시 알람을 보낼 슬랙 채널

#### Secrets Variables
- `password` - edge device의 비밀번호
- `otp` - otp 생성기 설정번호

-------------------------------

### Example
#### inference 프로세스를 재시작
```diff
name: Restart After Deployment

on:
  # manually trigger
  workflow_dispatch:

jobs:
  restart-process-in-edge:
    uses: teamdable/vv-deploy-actions/.github/workflows/restart_process_after_deploy.yml@main
    with:
      user: 'ubuntu'
!     process-name: 'inference'
!     slack-channel: 'general'
    secrets:
      password: ${{ secrets.PASSWORD }}
      otp: ${{ secrets.OTP }}
```


## parallel-deployment
### Variables

#### Input variables
[deploy-actions](#deploy-actions)의 input, secret 변수와 모두 동일하나 `process-name`이 추가된다
- `process-name`: 배포중간에 실행중인 프로세스를 끄고 켤때 필요하다. 

    start-{process-name}, kill-{process-name} 명령어와 같이 사용되므로 
    
    resource-monitoring, inference, edge-player ... 형태로 입력한다

### Example
배포하려는 소스코드의 repository에서는 workflow파일에서 vv-deploy-actions의 reusable workflows를 호출한다. ( 아래의 1번, 2번 과정을 따른다. )
1. `bin/deploy/install-settings.sh` 파일을 작성한다. 예시는 [example/](https://github.com/teamdable/vv-deploy-actions/blob/main/example/)에서 확인할 수 있다.
2. `.github/workflows/your-workflow-name.yml`를 작성한다. 예시는 아래에서 확인할 수 있다.
       
    ```yaml
    name: Parallel Deployment
	
    on:
      workflow_dispatch:
        inputs:
          deploy-target-devices:
            description: '배포할 device_id를 입력하세요 (SN1-001, SN1-002 ... )'
            required: true
            type: string
          deploy-message:
            description: '배포 내용/유의사항 등을 입력하세요'
            required: true
            type: string
    jobs:
      CD:
        uses: teamdable/vv-deploy-actions/.github/workflows/deployment-with-restart.yml@main
        with:
          deploy-target-device: ${{ github.event.inputs.deploy-target-devices }}
          user: 'ubuntu'
          code-name: 'resource'
          deploy-branch: ${GITHUB_REF##*/}
          parent-dir: '/home/ubuntu'
          version-file-name: '_version.py'
          exclude-files-from-zip: 'bin/deploy/vpn-config.ini'
          slack-channel: 'general'
          process-name: 'resource-monitoring'
		  deploy-message: ${{ github.event.inputs.deploy-message }}
        secrets:
          password: ${{ secrets.REMOTE_PASSWD }}
          otp: ${{ secrets.GOOGLE_KEY }}
    ```
