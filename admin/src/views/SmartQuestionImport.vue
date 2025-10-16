<template>
  <div class="smart-question-import">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>智能题目上传</span>
          <el-button type="text" @click="showHelp = true">使用帮助</el-button>
        </div>
      </template>

      <el-form :model="importOptions" label-width="120px">
        <el-form-item label="选择题库：" required>
          <el-select v-model="importOptions.questionBankId" placeholder="请选择题库" @change="onQuestionBankChange" style="width: 100%">
            <el-option v-for="bank in questionBanks" :key="bank.id" :label="bank.name" :value="bank.id" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="选择科目：" required>
          <el-select v-model="importOptions.subjectId" placeholder="请选择科目" style="width: 100%" :disabled="!importOptions.questionBankId">
            <el-option v-for="subject in subjects" :key="subject.id" :label="subject.name" :value="subject.id" />
          </el-select>
        </el-form-item>

        <el-form-item label="上传模式：">
          <el-radio-group v-model="uploadMode">
            <el-radio label="smart">智能解析</el-radio>
            <el-radio label="manual">手动导入</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="上传文件：">
          <el-upload
            ref="uploadRef"
            :auto-upload="false"
            :on-change="handleFileChange"
            :before-upload="beforeUpload"
            :file-list="fileList"
            :limit="1"
            :on-exceed="handleExceed"
            :on-remove="handleRemove"
            :accept="uploadMode === 'smart' ? '.docx,.doc,.xlsx,.xls,.pdf,.txt' : '.xlsx,.xls,.csv'"
            drag
          >
            <el-icon class="el-icon--upload"><upload-filled /></el-icon>
            <div class="el-upload__text">
              将文件拖到此处，或<em>点击上传</em>
            </div>
            <template #tip>
              <div class="el-upload__tip">
                <span v-if="uploadMode === 'smart'">
                  智能模式：支持 Word、Excel、PDF、TXT 格式，自动解析题目结构
                </span>
                <span v-else>
                  手动模式：支持 Excel、CSV 格式，需要标准表格结构
                </span>
              </div>
            </template>
          </el-upload>
        </el-form-item>

        <el-form-item v-if="uploadMode === 'manual'" label="重复处理：">
          <el-radio-group v-model="importOptions.duplicateHandling">
            <el-radio label="skip">跳过重复</el-radio>
            <el-radio label="replace">替换重复</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item>
          <div class="button-group">
            <div class="primary-actions">
              <el-button 
                type="primary" 
                @click="previewParse" 
                :loading="previewing" 
                v-if="uploadMode === 'smart'"
                size="large"
              >
                <el-icon><View /></el-icon>
                预览解析
              </el-button>
              <el-button 
                type="success" 
                @click="confirmImport" 
                :loading="importing" 
                :disabled="!canImport"
                size="large"
              >
                <el-icon><Upload /></el-icon>
                {{ uploadMode === 'smart' ? '确认导入' : '确认导入' }}
              </el-button>
            </div>
            <div class="secondary-actions">
              <el-button @click="resetForm" size="default">
                <el-icon><RefreshLeft /></el-icon>
                重置
              </el-button>
            </div>
          </div>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 智能解析预览 -->
    <el-card v-if="smartPreviewData.length > 0" style="margin-top: 20px;">
      <template #header>
        <div class="card-header">
          <span>智能解析预览</span>
          <div>
            <el-tag type="success">有效: {{ smartPreviewData.filter(q => q.isValid).length }}</el-tag>
            <el-tag type="danger" style="margin-left: 10px;">无效: {{ smartPreviewData.filter(q => !q.isValid).length }}</el-tag>
          </div>
        </div>
      </template>

      <el-table :data="smartPreviewData" border style="width: 100%">
        <el-table-column prop="number" label="题号" width="80" />
        <el-table-column prop="content" label="题目内容" width="300" show-overflow-tooltip />
        <el-table-column prop="type" label="类型" width="100">
          <template #default="scope">
            <el-tag :type="getTypeTagType(scope.row.type)">
              {{ getTypeText(scope.row.type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="options" label="选项" width="200" show-overflow-tooltip>
          <template #default="scope">
            <div v-for="opt in scope.row.options" :key="opt.key" style="margin: 2px 0;">
              <strong>{{ opt.key }}.</strong> {{ opt.content }}
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="answer" label="答案" width="80" />
        <el-table-column prop="explanation" label="解析" width="200" show-overflow-tooltip>
          <template #default="scope">
            <div>
              <div>{{ scope.row.explanation }}</div>
              <!-- 显示解析中的图片 -->
              <div v-if="scope.row.images && scope.row.images.length > 0" style="margin-top: 8px;">
                <div v-for="(image, index) in scope.row.images" :key="index" style="margin: 4px 0;">
                  <el-image
                    :src="getImageUrl(image.path)"
                    :preview-src-list="getImagePreviewList(scope.row.images)"
                    style="width: 60px; height: 40px; border-radius: 4px;"
                    fit="cover"
                    :initial-index="index"
                  />
                </div>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="images" label="图片数量" width="100">
          <template #default="scope">
            <el-tag v-if="scope.row.images && scope.row.images.length > 0" type="info">
              {{ scope.row.images.length }}张
            </el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="isValid" label="状态" width="120">
          <template #default="scope">
            <div>
              <el-tag :type="scope.row.isValid ? 'success' : 'danger'">
                {{ scope.row.isValid ? '有效' : '无效' }}
              </el-tag>
              <div v-if="!scope.row.isValid && scope.row.invalidReasons && scope.row.invalidReasons.length > 0" 
                   style="margin-top: 4px; font-size: 12px; color: #f56c6c;">
                <el-tooltip :content="scope.row.invalidReasons.join('；')" placement="top">
                  <span style="cursor: help; text-decoration: underline;">
                    {{ scope.row.invalidReasons.length }}个问题
                  </span>
                </el-tooltip>
              </div>
            </div>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 手动导入预览 -->
    <el-card v-if="previewData.length > 0" style="margin-top: 20px;">
      <template #header>
        <div class="card-header">
          <span>预览数据 ({{ previewData.length }} 条)</span>
        </div>
      </template>

      <el-table :data="previewData" border style="width: 100%">
        <el-table-column prop="content" label="题目内容" width="300" show-overflow-tooltip />
        <el-table-column prop="type" label="题目类型" width="100" />
        <el-table-column prop="options" label="选项" width="200" show-overflow-tooltip />
        <el-table-column prop="answer" label="答案" width="80" />
        <el-table-column prop="explanation" label="解析" width="200" show-overflow-tooltip />
        <el-table-column prop="isValid" label="状态" width="120">
          <template #default="scope">
            <div>
              <el-tag :type="scope.row.isValid ? 'success' : 'danger'">
                {{ scope.row.isValid ? '有效' : '无效' }}
              </el-tag>
              <div v-if="!scope.row.isValid && scope.row.invalidReasons && scope.row.invalidReasons.length > 0" 
                   style="margin-top: 4px; font-size: 12px; color: #f56c6c;">
                <el-tooltip :content="scope.row.invalidReasons.join('；')" placement="top">
                  <span style="cursor: help; text-decoration: underline;">
                    {{ scope.row.invalidReasons.length }}个问题
                  </span>
                </el-tooltip>
              </div>
            </div>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 使用帮助对话框 -->
    <el-dialog v-model="showHelp" title="智能上传使用帮助" width="800px">
      <el-tabs>
        <el-tab-pane label="智能解析模式" name="smart">
          <h4>支持的文件格式：</h4>
          <ul>
            <li><strong>Word文档 (.docx, .doc)</strong> - 支持包含图片的文档</li>
            <li><strong>Excel表格 (.xlsx, .xls)</strong> - 支持表格格式</li>
            <li><strong>PDF文档 (.pdf)</strong> - 支持PDF格式</li>
            <li><strong>文本文档 (.txt)</strong> - 支持纯文本格式</li>
          </ul>
          
          <h4>题目格式要求：</h4>
          <pre style="background: #f5f5f5; padding: 10px; border-radius: 4px;">
1. 以下哪个选项是正确的？
A. 选项A的内容
B. 选项B的内容
C. 选项C的内容
D. 选项D的内容
答案：A
解析：这是解析内容

2. 第二道题目...
A. 选项A
B. 选项B
答案：B
解析：解析内容</pre>
          
          <h4>自动识别功能：</h4>
          <ul>
            <li>自动识别题目序号（1.、1、第1题等）</li>
            <li>自动识别选项（A.、A、等）</li>
            <li>自动识别答案（答案：A、正确答案：A等）</li>
            <li>自动识别解析（解析：、解答：等）</li>
            <li>自动提取图片并关联到题目</li>
            <li>自动判断题目类型（单选、多选、判断）</li>
          </ul>
        </el-tab-pane>
        
        <el-tab-pane label="手动导入模式" name="manual">
          <h4>支持的文件格式：</h4>
          <ul>
            <li><strong>Excel表格 (.xlsx, .xls)</strong></li>
            <li><strong>CSV文件 (.csv)</strong></li>
          </ul>
          
          <h4>表格结构要求：</h4>
          <table border="1" style="width: 100%; border-collapse: collapse;">
            <thead>
              <tr>
                <th>题目内容</th>
                <th>选项A</th>
                <th>选项B</th>
                <th>选项C</th>
                <th>选项D</th>
                <th>答案</th>
                <th>解析</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>以下哪个选项是正确的？</td>
                <td>选项A的内容</td>
                <td>选项B的内容</td>
                <td>选项C的内容</td>
                <td>选项D的内容</td>
                <td>A</td>
                <td>这是解析内容</td>
              </tr>
            </tbody>
          </table>
        </el-tab-pane>
      </el-tabs>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { UploadFilled, View, Upload, RefreshLeft } from '@element-plus/icons-vue'
import { useRouter } from 'vue-router'
import { questionBankAPI } from '../api/questionBank'
import { subjectAPI } from '../api/subject'
import { questionAPI } from '../api/question'
import { adminAPI } from '../api/admin'

const router = useRouter()

// 获取服务器URL
const getServerUrl = () => {
  // 生产环境走同域名，通过nginx代理到后端API
  if (import.meta.env.PROD) {
    return ''
  }
  // 开发环境使用环境变量或默认远端
  return import.meta.env.VITE_SERVER_URL || 'https://practice.insightdata.top'
}

// 响应式数据
const uploadMode = ref('smart')
const showHelp = ref(false)
const previewing = ref(false)
const importing = ref(false)
const fileList = ref([])
const previewData = ref([])
const smartPreviewData = ref([])
const uploadRef = ref(null)

const importOptions = reactive({
  questionBankId: '',
  subjectId: '',
  duplicateHandling: 'skip'
})

const questionBanks = ref([])
const subjects = ref([])

// 计算属性
const canImport = computed(() => {
  return importOptions.questionBankId && 
         importOptions.subjectId && 
         fileList.value.length > 0
})

// 生命周期
onMounted(() => {
  loadQuestionBanks()
  
  // 监听fileList的变化
  watch(fileList, (newVal, oldVal) => {
    console.log('fileList发生变化:', {
      old: oldVal,
      new: newVal,
      oldLength: oldVal?.length,
      newLength: newVal?.length
    })
  }, { deep: true })
})

// 方法
const loadQuestionBanks = async () => {
  try {
    console.log('开始加载题库列表...')
    const response = await questionBankAPI.getQuestionBanks()
    console.log('题库API响应:', response)
    
    if (response.code === 200) {
      questionBanks.value = response.data.list || response.data.rows || response.data || []
      console.log('加载到的题库:', questionBanks.value)
    } else {
      console.error('API返回错误:', response.message)
      ElMessage.error(response.message || '加载题库列表失败')
    }
  } catch (error) {
    console.error('加载题库列表失败:', error)
    ElMessage.error('加载题库列表失败: ' + error.message)
  }
}

const loadSubjects = async (questionBankId) => {
  try {
    console.log('开始加载科目列表，题库ID:', questionBankId)
    const response = await subjectAPI.getSubjects({ questionBankId })
    console.log('科目API响应:', response)
    
    if (response.code === 200) {
      subjects.value = response.data.list || response.data.rows || response.data || []
      console.log('加载到的科目:', subjects.value)
    } else {
      console.error('科目API返回错误:', response.message)
      ElMessage.error(response.message || '加载科目列表失败')
    }
  } catch (error) {
    console.error('加载科目列表失败:', error)
    ElMessage.error('加载科目列表失败: ' + error.message)
  }
}

const onQuestionBankChange = (questionBankId) => {
  importOptions.subjectId = ''
  subjects.value = []
  if (questionBankId) {
    loadSubjects(questionBankId)
  }
}

const handleFileChange = (file) => {
  console.log('=== 文件变化回调 ===')
  console.log('文件对象:', file)
  console.log('文件raw属性:', file.raw)
  
  // 简化文件处理逻辑，与普通上传页面保持一致
  fileList.value = [file]
  console.log('更新后fileList.value:', fileList.value)
  console.log('更新后长度:', fileList.value.length)
}

const handleExceed = (files, fileListParam) => {
  ElMessage.warning('只能上传一个文件，请先删除当前文件再上传新文件')
}

const handleRemove = (file) => {
  console.log('移除文件:', file)
  fileList.value = []
}

const beforeUpload = (file) => {
  const isValidType = uploadMode.value === 'smart' 
    ? /\.(docx|doc|xlsx|xls|pdf|txt)$/i.test(file.name)
    : /\.(xlsx|xls|csv)$/i.test(file.name)
  
  if (!isValidType) {
    ElMessage.error('文件格式不正确')
    return false
  }
  
  const isLt50M = file.size / 1024 / 1024 < 50
  if (!isLt50M) {
    ElMessage.error('文件大小不能超过 50MB')
    return false
  }
  
  return true
}

const previewParse = async () => {
  console.log('=== 开始预览解析 ===')
  console.log('当前fileList.value:', fileList.value)
  console.log('文件列表长度:', fileList.value.length)
  
  if (!fileList.value.length) {
    ElMessage.warning('请先选择文件')
    return
  }

  const file = fileList.value[0]
  console.log('选择的文件:', file)
  console.log('文件对象的所有属性:', Object.keys(file))
  console.log('file.raw:', file.raw)
  console.log('file.raw类型:', typeof file.raw)
  console.log('file.raw是否为File对象:', file.raw instanceof File)
  
  // 尝试多种方式获取文件对象
  let fileToUpload = file.raw
  
  // 如果raw不存在，尝试其他属性
  if (!fileToUpload) {
    console.log('file.raw不存在，尝试其他属性')
    fileToUpload = file.originFileObj || file.file || file
    console.log('备用文件对象:', fileToUpload)
  }
  
  if (!fileToUpload) {
    ElMessage.warning('文件数据无效，请重新选择文件')
    return
  }

  previewing.value = true
  try {
    const formData = new FormData()
    formData.append('file', fileToUpload)
    
    console.log('发送的FormData:', formData)
    console.log('FormData中的file字段:', formData.get('file'))
    console.log('FormData中的file字段类型:', typeof formData.get('file'))
    
    const response = await fetch(`${getServerUrl()}/api/enhanced-question/preview-parse`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      },
      body: formData
    })
    
    const result = await response.json()
    
    if (result.code === 200) {
      smartPreviewData.value = result.data.questions || []
      ElMessage.success(`解析完成，共识别 ${result.data.total} 道题目`)
    } else {
      ElMessage.error(result.message || '解析失败')
    }
  } catch (error) {
    console.error('预览解析失败:', error)
    ElMessage.error('预览解析失败')
  } finally {
    previewing.value = false
  }
}

const confirmImport = async () => {
  if (!canImport.value) {
    ElMessage.warning('请完善必填信息')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确定要导入题目到题库"${getSelectedBankName()}"的科目"${getSelectedSubjectName()}"吗？`,
      '确认导入',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    importing.value = true

    if (uploadMode.value === 'smart') {
      await smartImport()
    } else {
      await manualImport()
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('导入失败:', error)
      ElMessage.error('导入失败: ' + error.message)
    }
  } finally {
    importing.value = false
  }
}

const smartImport = async () => {
  try {
    console.log('=== 开始智能导入 ===')
    console.log('当前fileList.value:', fileList.value)
    console.log('文件列表长度:', fileList.value.length)
    
    if (!fileList.value.length) {
      ElMessage.error('请先选择文件')
      return
    }
    
    const file = fileList.value[0]
    
    // 尝试多种方式获取文件对象
    let fileToUpload = file.raw || file.originFileObj || file.file || file
    
    if (!file || !fileToUpload) {
      ElMessage.error('文件数据无效，请重新选择文件')
      return
    }
    
    const formData = new FormData()
    formData.append('file', fileToUpload)
    formData.append('questionBankId', importOptions.questionBankId)
    formData.append('subjectId', importOptions.subjectId)
    formData.append('fileType', getFileExtension(file.name))
    
    const response = await fetch(`${getServerUrl()}/api/enhanced-question/smart-upload`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      },
      body: formData
    })
    
    const result = await response.json()
    
    if (result.code === 200) {
      ElMessage.success(`成功导入 ${result.data.saved} 道题目`)
      router.push('/question-bank-management')
    } else {
      ElMessage.error(result.message || '导入失败')
    }
  } catch (error) {
    console.error('智能导入失败:', error)
    ElMessage.error('智能导入失败')
  }
}

const manualImport = async () => {
  try {
    const questionsToImport = previewData.value
      .filter(item => item.isValid)
      .map(item => ({
        questionBankId: importOptions.questionBankId,
        subjectId: importOptions.subjectId,
        chapter: item.chapter || '',
        content: item.content,
        type: item.type,
        options: item.options,
        answer: item.answer,
        explanation: item.explanation,
        images: item.images || []
      }))

    const response = await questionAPI.importQuestions(questionsToImport)
    
    if (response.code === 200) {
      const selectedBank = questionBanks.value.find(b => b.id === importOptions.questionBankId)
      const selectedSubject = subjects.value.find(s => s.id === importOptions.subjectId)
      
      ElMessage.success(`成功导入 ${questionsToImport.length} 道题目到题库"${selectedBank?.name}"的科目"${selectedSubject?.name}"`)
      router.push('/question-bank-management')
    } else {
      ElMessage.error(response.message || '导入失败')
    }
  } catch (error) {
    console.error('手动导入失败:', error)
    ElMessage.error('手动导入失败')
  }
}

const resetForm = () => {
  importOptions.questionBankId = ''
  importOptions.subjectId = ''
  importOptions.duplicateHandling = 'skip'
  fileList.value = []
  previewData.value = []
  smartPreviewData.value = []
  subjects.value = []
}

const getSelectedBankName = () => {
  const bank = questionBanks.value.find(b => b.id === importOptions.questionBankId)
  return bank?.name || ''
}

const getSelectedSubjectName = () => {
  const subject = subjects.value.find(s => s.id === importOptions.subjectId)
  return subject?.name || ''
}

const getFileExtension = (filename) => {
  return filename.split('.').pop().toLowerCase()
}

const getTypeTagType = (type) => {
  const typeMap = {
    'single': 'primary',
    'multiple': 'success',
    'judge': 'warning'
  }
  return typeMap[type] || 'info'
}

const getTypeText = (type) => {
  const typeMap = {
    'single': '单选题',
    'multiple': '多选题',
    'judge': '判断题'
  }
  return typeMap[type] || '未知'
}

const debugFileList = () => {
  console.log('=== 调试文件列表 ===')
  console.log('fileList.value:', fileList.value)
  console.log('fileList.value长度:', fileList.value.length)
  console.log('uploadRef.value:', uploadRef.value)
  console.log('uploadRef.value?.uploadFiles:', uploadRef.value?.uploadFiles)
  console.log('uploadRef.value?.uploadFiles长度:', uploadRef.value?.uploadFiles?.length)
  
  if (uploadRef.value?.uploadFiles) {
    uploadRef.value.uploadFiles.forEach((file, index) => {
      console.log(`文件${index + 1}:`, file)
    })
  }
}

// 图片URL处理
const getImageUrl = (imagePath) => {
  if (!imagePath) return ''
  
  // 如果是相对路径，添加服务器地址
  if (imagePath.startsWith('/images/')) {
    return `${getServerUrl()}${imagePath}`
  }
  
  return imagePath
}

// 获取图片预览列表
const getImagePreviewList = (images) => {
  if (!images || !Array.isArray(images)) return []
  return images.map(image => getImageUrl(image.path))
}
</script>

<style scoped>
.smart-question-import {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.el-upload__tip {
  color: #999;
  font-size: 12px;
  margin-top: 5px;
}

.el-table {
  margin-top: 20px;
}

pre {
  white-space: pre-wrap;
  word-wrap: break-word;
}

table {
  margin-top: 10px;
}

th, td {
  padding: 8px;
  text-align: left;
  border: 1px solid #ddd;
}

th {
  background-color: #f5f5f5;
  font-weight: bold;
}

/* 按钮组样式 */
.button-group {
  display: flex;
  flex-direction: column;
  gap: 16px;
  width: 100%;
}

.primary-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
  flex-wrap: wrap;
}

.secondary-actions {
  display: flex;
  justify-content: center;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .primary-actions {
    flex-direction: column;
    align-items: center;
  }
  
  .primary-actions .el-button {
    width: 200px;
  }
  
  .secondary-actions .el-button {
    width: 120px;
  }
}
</style>
