# vv-deploy-actions

## Variables
### Input variables
- `user` - edge device의 사용자 이름
- `code-name` - 배포하고자하는 코드 모듈 이름(배포 장비에서 사용되는 프로젝트 루트명을 따른다.) \
e.g. edge-player, process, resource
- `code-version` - 배포하고자하는 모듈의 버전 파일 \
e.g. _version.py, .version
- `parent-dir` - 배포 장비에서 모듈의 부모 경로 \
e.g. `/home/${user}`
- `version-file-name` - 배포하고자하는 모듈의 버전 파일 이름 \
e.g.  _version.py or .version
- `exclude-files-from-zip` - 소스코드 압축파일에서 제외한 파일들 이름 \
e.g. \_\_pycache\_\_/*


### Secrets Variables
- `tailscale-authkey` - tailnet에 github runner를 node로 추가하기 위한 tailscale authkey
- `password` - edge device의 비밀번호

## Usage
vv-deploy-actions의 reusable workflows를 활용하는 레포지토리에 `bin/deploy/install-settings.sh`, `bin/deploy/vpn-config.ini` 파일들이 필요하다. 예시는 [example/](https://github.com/teamdable/vv-deploy-actions/blob/main/example/)에서 확인할 수 있다.

`.github/workflows/your-workflow-name.yml`의 예시는 아래에서 확인할 수 있다.
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
    secrets:
      tailscale-authkey: ${{ secrets.TAILSCALE_AUTHKEY }}
      password: ${{ secrets.PASSWORD }}
      otp: ${{ secrets.OTP }}
```

output: 
<details>
<summary>Add runner to the tailnet</summary>

- Success
	```
	Success.
	```

- Fail: 정상적으로 tailscale authkey가 전달되지않았거나, key가 expire된 경우에는 이 step에서 종료됩니다.
</details>

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

	Deploy와 Install에 실패한 기기들의 hostname은 다음과 같습니다
	Deploy: 
	Install:
	```

- Fail: 모든 HOST에 배포를 진행하고, 과정이 완료된 후에 하나라도 배포가 실패했을 시에 Actions가 실패합니다.

	```
	hostname: 127.0.0.2
	build & deploy Success
	[err] target version과 source version이 일치하지않습니다

	hostname: 127.0.0.3
	[err] 배포 대상 edge device에 deploy 작업이 제대로 루어지지않았습니다

	Deploy와 Install에 실패한 기기들의 hostname은 다음과 습니다
	Deploy: 127.0.0.3
	Install: 127.0.0.2 127.0.0.3
	```
</details>


## Example
#### 1. 프로세스 모니터링 모듈을 배포대상 장비의 ~/monitoring/process로 배포
- 버전을 표기하는 메타데이터를 _version.py로 명시한다.
- 배포 압축 파일에서 복수개의 파일들을 제외한다.
```diff
uses: teamdable/vv-deploy-actions/.github/workflows/deploy-to-edge-devices.yml@main
with:
    user: 'ubuntu'
!   code-name: 'process'
!   parent-dir: '/home/ubuntu/monitoring/'
!   version-file-name: '_version.py'
-   exclude-files-from-zip: 'bin/deploy/vpn-config.ini'
+   exclude-files-from-zip: 'bin/deploy/vpn-config.ini __pycache__/*'
secrets:
    tailscale-authkey: ${{ secrets.TAILSCALE_AUTHKEY }}
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
!   parent-dir: '/home/ubuntu/'
!   version-file-name: '_version.py'
-   exclude-files-from-zip: 'bin/deploy/vpn-config.ini'
+   
secrets:
    tailscale-authkey: ${{ secrets.TAILSCALE_AUTHKEY }}
    password: ${{ secrets.PASSWORD }}
    otp: ${{ secrets.OTP }}
```
