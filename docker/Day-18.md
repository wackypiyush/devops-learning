# Amazon ECR & Docker Registry Notes

---

## 1. Container Registry
A **container registry** is a centralized service for storing, managing, and distributing container images.

- Developers **push** images to the registry.
- Deployments (Docker, Kubernetes, ECS/EKS) **pull** images from it.
- Registries provide **versioning, access control, and vulnerability scanning**.

---

## 2. Docker Hub vs Amazon ECR

| Feature            | Docker Hub                                      | Amazon ECR (Elastic Container Registry) |
|--------------------|-------------------------------------------------|-----------------------------------------|
| **Primary Use Case** | Public image sharing, open-source projects, small teams | Private enterprise registry, AWS-native workloads |
| **Integration**    | Works with any Docker/Kubernetes setup          | Deep integration with AWS ECS, EKS, CodePipeline |
| **Authentication** | Username/password, tokens                       | AWS IAM roles, resource policies |
| **Best For**       | Public images, open-source, quick prototyping   | Enterprise workloads, secure private registries, AWS-native CI/CD |
| **Avoid When**     | Enterprise security/compliance is critical      | Multi-cloud or non-AWS environments (IAM coupling adds friction) |

---

## 3. Key Terms

### Registry
- The **service** that stores and distributes container images.  
- Think of it as the “library” or “warehouse.”  
- Examples: Docker Hub, Amazon ECR, GitHub Container Registry, Google Artifact Registry.

### Repository
- A **collection of related images** within a registry.  
- Usually corresponds to one application or service.  
- Example:  
  - Registry: `docker.io`  
  - Repository: `nginx`  
  - Together: `docker.io/nginx`

### Tag
- A **label** pointing to a specific image version inside a repository.  
- Example:  
  - `nginx:1.25.3` → Nginx version 1.25.3  
  - `nginx:latest` → latest build published

---

## 4. Amazon ECR Image URI

**Syntax**:  
```
ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/REPOSITORY:TAG
```

**Example**:  
```
123456789012.dkr.ecr.ap-south-1.amazonaws.com/myapp:v1
```

**Breakdown**:
- `123456789012` → AWS Account ID  
- `dkr.ecr` → ECR Docker registry endpoint  
- `ap-south-1` → AWS Region (Mumbai)  
- `myapp` → Repository name  
- `v1` → Image tag (version)

---

## 5. AWS ECR Repository Commands

**Create repository**:
```bash
aws ecr create-repository --repository-name devops-day18
```

**Verify repository**:
```bash
aws ecr describe-repositories --repository-names devops-day18
```

**List images**:
```bash
aws ecr list-images --repository-name devops-day18
```

**Describe images**:
```bash
aws ecr describe-images --repository-name devops-day18
```

Look for:
- `imageTags`
- `imageDigest`
- `imageSizeInBytes`
- `imagePushedAt`

---

## 6. Tags (Local vs Remote)

Local image:
```
devops-day18:v1
```

Remote ECR tag:
```
123456789012.dkr.ecr.ap-south-1.amazonaws.com/devops-day18:v1
```

**Tagging command**:
```bash
docker tag devops-day18:v1 \
123456789012.dkr.ecr.ap-south-1.amazonaws.com/devops-day18:v1
```

- `docker tag` does **not copy** the image.  
- It creates another **reference (alias)**.  
- Push happens later with:
```bash
docker push 123456789012.dkr.ecr.ap-south-1.amazonaws.com/devops-day18:v1
```

---

## 7. Authenticate Docker With ECR

```bash
aws ecr get-login-password --region <REGION> \
| docker login \
  --username AWS \
  --password-stdin <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com
```

**Flow**:
```
AWS CLI → get-login-password → temporary token → docker login → authenticated to ECR
```

---

## 8. Tag vs Digest

- **Tag** → Human-friendly (`v1`, `latest`), mutable.  
- **Digest** → Content-based (`sha256:...`), immutable.  

Example:
```bash
docker pull nginx:1.25.3
```
Resolves to:
```
nginx@sha256:3c3d2f9a...
```

**Why it matters**:
- Reproducibility  
- Security  
- Kubernetes deployments often pin by digest

---

## 9. Pull Image from ECR

1. Remove local image (optional):
```bash
docker rmi <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/devops-day18:v1
```

2. Authenticate:
```bash
aws ecr get-login-password --region <REGION> \
| docker login --username AWS \
--password-stdin <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com
```

3. Pull:
```bash
docker pull <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/devops-day18:v1
```

---

## 10. Run Image from ECR

```bash
docker run --rm -p 5000:5000 \
<ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/devops-day18:v1
```

Test:
```bash
curl http://localhost:5000
```

---

## 11. Why ECR Is Useful for Jenkins

**Workflow**:
```
Developer → GitHub → Jenkins
       ↓
docker build → docker test → docker tag → docker login ECR → docker push ECR
       ↓
ECR (image storage)
       ↓
EKS (deployment)
```

**Benefits**:
- Separation of concerns (CI vs CD)  
- IAM-based security  
- Scalability across clusters  
- Reproducibility with tags/digests  

---

## 12. ECR Security Concepts
- Access controlled via **AWS IAM** (users, roles, policies).  
- Jenkins pipelines use IAM roles/credentials for secure push/pull.  

---

## 13. Troubleshooting ECR Push Failures

1. Check AWS identity → `aws sts get-caller-identity`  
2. Verify region → `aws configure get region`  
3. Confirm repository → `aws ecr describe-repositories`  
4. Check Docker login → `docker login`  
5. Inspect image tag → `docker images`  
6. Validate repository URI → `aws ecr describe-repositories`  
7. Retry push → `docker push ...`

---

## 14. Common Errors

- **No Basic Authentication Credentials** → Not logged in.  
  Fix:
  ```bash
  aws ecr get-login-password --region <REGION> \
  | docker login --username AWS --password-stdin <ECR_REGISTRY>
  ```

- **Repository Does Not Exist** → Create with `aws ecr create-repository`.

- **Wrong Tag** → Retag with `docker tag`.

- **Wrong Region** → Ensure correct region in AWS CLI.

- **AccessDenied** → IAM permissions missing.  
  ⚠️ Don’t fix by granting `AdministratorAccess`. Use least privilege.

---
```
