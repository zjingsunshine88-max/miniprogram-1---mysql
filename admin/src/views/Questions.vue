<template>
  <div class="questions-page">
    <!-- 科目列表页面 -->
    <div v-if="!currentSubject" class="bank-list-page">
      <el-card>
        <template #header>
        <div class="card-header">
          <span>科目管理</span>
          <div class="header-actions">
            <el-button type="primary" @click="$router.push('/question-import')">
              <el-icon><Upload /></el-icon>
              导入题目
            </el-button>
            <el-button @click="loadSubjects">
              <el-icon><Refresh /></el-icon>
              刷新
            </el-button>
          </div>
        </div>
        </template>

        <!-- 搜索和筛选 -->
        <div class="search-section">
          <el-row :gutter="20">
            <el-col :span="6">
              <el-input
                v-model="searchForm.keyword"
                placeholder="搜索科目名称"
                clearable
                @keyup.enter="handleSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
            </el-col>
            <el-col :span="4">
              <el-select v-model="searchForm.subject" placeholder="选择科目" clearable>
                <el-option label="全部科目" value="" />
                <el-option
                  v-for="subject in subjectOptions"
                  :key="subject"
                  :label="subject"
                  :value="subject"
                />
              </el-select>
            </el-col>
            <el-col :span="4">
              <el-select v-model="searchForm.difficulty" placeholder="难度" clearable>
                <el-option label="全部难度" value="" />
                <el-option label="简单" value="简单" />
                <el-option label="中等" value="中等" />
                <el-option label="困难" value="困难" />
              </el-select>
            </el-col>
            <el-col :span="6">
              <el-button type="primary" @click="handleSearch">搜索</el-button>
              <el-button @click="resetSearch">重置</el-button>
            </el-col>
          </el-row>
        </div>

        <!-- 科目列表 -->
        <div class="bank-grid">
          <el-card
            v-for="subject in subjects"
            :key="subject.id"
            class="bank-card"
            shadow="hover"
            @click="enterSubject(subject)"
          >
            <div class="bank-info">
              <h3 class="bank-name">{{ subject.name }}</h3>
              <div class="bank-meta">
                <el-tag :type="getSubjectTagType(subject.name)">{{ subject.name }}</el-tag>
                <el-tag :type="getDifficultyTagType(subject.difficulty)">{{ subject.difficulty }}</el-tag>
              </div>
              <div class="bank-stats">
                <span class="stat-item">
                  <el-icon><Document /></el-icon>
                  {{ subject.questionCount || 0 }} 题
                </span>
                <span class="stat-item">
                  <el-icon><Calendar /></el-icon>
                  {{ formatDate(subject.createdAt) }}
                </span>
              </div>
            </div>
            <div class="bank-actions">
              <el-button size="small" type="primary" @click.stop="enterSubject(subject)">
                进入科目
              </el-button>
              <el-button size="small" type="danger" @click.stop="deleteSubject(subject)">
                删除
              </el-button>
            </div>
          </el-card>
        </div>

        <!-- 分页 -->
        <div class="pagination">
          <el-pagination
            v-model:current-page="pagination.page"
            v-model:page-size="pagination.limit"
            :page-sizes="[12, 24, 48]"
            :total="pagination.total"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </el-card>
    </div>

    <!-- 题目列表页面 -->
    <div v-else class="question-list-page">
      <el-card>
        <template #header>
          <div class="card-header">
            <div class="header-left">
              <el-button @click="backToSubjects" type="text">
                <el-icon><ArrowLeft /></el-icon>
                返回科目列表
              </el-button>
              <span class="bank-title">{{ currentSubject.name }}</span>
            </div>
            <div class="header-actions">
              <el-button type="primary" @click="showAddDialog = true">
                <el-icon><Plus /></el-icon>
                添加题目
              </el-button>
              <el-button @click="loadQuestions">
                <el-icon><Refresh /></el-icon>
                刷新
              </el-button>
            </div>
          </div>
        </template>

        <!-- 搜索和筛选 -->
        <div class="search-section">
          <el-row :gutter="20">
            <el-col :span="6">
              <el-input
                v-model="searchForm.keyword"
                placeholder="搜索题目内容"
                clearable
                @keyup.enter="handleSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
            </el-col>
            <el-col :span="4">
              <el-select v-model="searchForm.type" placeholder="题目类型" clearable>
                <el-option label="全部类型" value="" />
                <el-option label="单选题" value="single" />
                <el-option label="多选题" value="multiple" />
                <el-option label="判断题" value="judge" />
              </el-select>
            </el-col>
            <el-col :span="6">
              <el-button type="primary" @click="handleSearch">搜索</el-button>
              <el-button @click="resetSearch">重置</el-button>
            </el-col>
          </el-row>
        </div>

        <!-- 题目列表 -->
        <el-table
          v-loading="loading"
          :data="questions"
          stripe
          style="width: 100%"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="type" label="类型" width="100">
            <template #default="{ row }">
              <el-tag :type="getTypeTagType(row.type)">
                {{ getTypeText(row.type) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="content" label="题目内容" min-width="300" show-overflow-tooltip />
          <el-table-column prop="answer" label="答案" width="100" />
          <el-table-column prop="createdAt" label="创建时间" width="180">
            <template #default="{ row }">
              {{ formatDate(row.createdAt) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="{ row }">
              <el-button size="small" @click="editQuestion(row)">编辑</el-button>
              <el-button size="small" type="danger" @click="deleteQuestion(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页 -->
        <div class="pagination">
          <el-pagination
            v-model:current-page="pagination.page"
            v-model:page-size="pagination.limit"
            :page-sizes="[10, 20, 50, 100]"
            :total="pagination.total"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </el-card>
    </div>

    <!-- 题目详情/编辑对话框 -->
    <el-dialog
      v-model="showDetailDialog"
      :title="editing ? '编辑题目' : '题目详情'"
      width="900px"
      :close-on-click-modal="false"
    >
      <div v-if="currentQuestion" class="question-detail">
        <!-- 编辑模式 -->
        <div v-if="editing" class="edit-form">
          <el-form :model="editForm" label-width="100px" label-position="left">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="题目ID">
                  <el-input v-model="editForm.id" disabled />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="科目">
                  <el-input v-model="editForm.subject" disabled />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="章节">
                  <el-input v-model="editForm.chapter" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="类型">
                  <el-select v-model="editForm.type" style="width: 100%">
                    <el-option label="单选题" value="单选题" />
                    <el-option label="多选题" value="多选题" />
                    <el-option label="判断题" value="判断题" />
                    <el-option label="填空题" value="填空题" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="难度">
                  <el-select v-model="editForm.difficulty" style="width: 100%">
                    <el-option label="简单" value="简单" />
                    <el-option label="中等" value="中等" />
                    <el-option label="困难" value="困难" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="正确答案">
                  <el-input v-model="editForm.answer" placeholder="如：A、AB、正确等" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-form-item label="题目内容">
              <el-input
                v-model="editForm.content"
                type="textarea"
                :rows="4"
                placeholder="请输入题目内容"
              />
            </el-form-item>

            <el-form-item label="选项">
              <div class="options-editor">
                <div v-for="(option, index) in editForm.options" :key="index" class="option-item">
                  <el-input
                    v-model="editForm.options[index].content"
                    :placeholder="`选项 ${String.fromCharCode(65 + index)}`"
                  >
                    <template #prepend>{{ String.fromCharCode(65 + index) }}.</template>
                  </el-input>
                  <el-button
                    v-if="editForm.options.length > 2"
                    type="danger"
                    size="small"
                    @click="removeOption(index)"
                  >
                    删除
                  </el-button>
                </div>
                <el-button
                  v-if="editForm.options.length < 6"
                  type="primary"
                  size="small"
                  @click="addOption"
                >
                  添加选项
                </el-button>
              </div>
            </el-form-item>

            <el-form-item label="解析">
              <el-input
                v-model="editForm.analysis"
                type="textarea"
                :rows="3"
                placeholder="请输入题目解析"
              />
            </el-form-item>

            <el-form-item label="解析图片">
              <div class="image-upload-section">
                <el-upload
                  ref="imageUploadRef"
                  :action="uploadUrl"
                  :headers="uploadHeaders"
                  :on-success="handleImageSuccess"
                  :on-error="handleImageError"
                  :before-upload="beforeImageUpload"
                  :file-list="editForm.images"
                  list-type="picture-card"
                  :limit="5"
                  accept="image/*"
                >
                  <el-icon><Plus /></el-icon>
                </el-upload>
                <div class="upload-tip">
                  支持上传JPG、PNG格式图片，最多5张
                </div>
              </div>
            </el-form-item>
          </el-form>
        </div>

        <!-- 查看模式 -->
        <div v-else>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="题目ID">{{ currentQuestion.id }}</el-descriptions-item>
            <el-descriptions-item label="科目">{{ currentQuestion.subject }}</el-descriptions-item>
            <el-descriptions-item label="章节">{{ currentQuestion.chapter }}</el-descriptions-item>
            <el-descriptions-item label="类型">
              <el-tag :type="getTypeTagType(currentQuestion.type)">
                {{ getTypeText(currentQuestion.type) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="难度">
              <el-tag :type="getDifficultyTagType(currentQuestion.difficulty)">
                {{ currentQuestion.difficulty }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="创建时间">
              {{ formatDate(currentQuestion.createdAt) }}
            </el-descriptions-item>
          </el-descriptions>

          <div class="question-content">
            <h4>题目内容：</h4>
            <p>{{ currentQuestion.content }}</p>

            <div v-if="currentQuestion.options && currentQuestion.options.length > 0">
              <h4>选项：</h4>
              <ul>
                <li v-for="(option, index) in currentQuestion.options" :key="index">
                  {{ String.fromCharCode(65 + index) }}. {{ option.content || option }}
                </li>
              </ul>
            </div>

            <div class="answer-section">
              <h4>正确答案：</h4>
              <p class="answer">{{ currentQuestion.answer }}</p>
            </div>

            <div v-if="currentQuestion.analysis">
              <h4>解析：</h4>
              <p>{{ currentQuestion.analysis }}</p>
            </div>

            <div v-if="currentQuestion.images && currentQuestion.images.length > 0">
              <h4>解析图片：</h4>
              <div class="images-grid">
                <el-image
                  v-for="(image, index) in currentQuestion.images"
                  :key="index"
                  :src="getImageUrl(image.path)"
                  :preview-src-list="getImagePreviewList()"
                  fit="cover"
                  class="analysis-image"
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showDetailDialog = false">取消</el-button>
          <el-button v-if="editing" type="primary" :loading="saving" @click="saveQuestion">
            保存
          </el-button>
          <el-button v-else type="primary" @click="startEdit">编辑</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 导入题目对话框 -->
    <el-dialog
      v-model="showImportDialog"
      title="导入题目"
      width="600px"
      :close-on-click-modal="false"
    >
      <div class="import-section">
        <el-alert
          title="导入说明"
          type="info"
          :closable="false"
          show-icon
        >
          <template #default>
            <p>支持导入Excel文件(.xlsx)或CSV文件(.csv)</p>
            <p>文件格式要求：</p>
            <ul>
              <li>第一行：科目,章节,类型,内容,选项A,选项B,选项C,选项D,正确答案,解析,难度</li>
              <li>类型：single(单选), multiple(多选), judge(判断)</li>
              <li>难度：简单, 中等, 困难</li>
            </ul>
          </template>
        </el-alert>

        <div class="upload-section">
          <el-upload
            ref="uploadRef"
            :auto-upload="false"
            :on-change="handleFileChange"
            :before-upload="beforeUpload"
            accept=".xlsx,.csv"
            drag
          >
            <el-icon class="el-icon--upload"><upload-filled /></el-icon>
            <div class="el-upload__text">
              将文件拖到此处，或<em>点击上传</em>
            </div>
            <template #tip>
              <div class="el-upload__tip">
                只能上传 xlsx/csv 文件
              </div>
            </template>
          </el-upload>
        </div>

        <div v-if="importData.length > 0" class="preview-section">
          <h4>预览数据 (前5条)：</h4>
          <el-table :data="importData.slice(0, 5)" size="small" max-height="200">
            <el-table-column prop="subject" label="科目" width="80" />
            <el-table-column prop="chapter" label="章节" width="100" />
            <el-table-column prop="type" label="类型" width="80" />
            <el-table-column prop="content" label="内容" show-overflow-tooltip />
            <el-table-column prop="answer" label="答案" width="80" />
          </el-table>
        </div>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showImportDialog = false">取消</el-button>
          <el-button
            type="primary"
            :loading="importing"
            :disabled="importData.length === 0"
            @click="handleImport"
          >
            确认导入 ({{ importData.length }} 条)
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Upload, UploadFilled, ArrowLeft, Plus, Document, Calendar } from '@element-plus/icons-vue'
import { adminAPI } from '../api/admin.js'

// 响应式数据
const loading = ref(false)
const questions = ref([])
const subjects = ref([])
const selectedQuestions = ref([])
const showDetailDialog = ref(false)
const showAddDialog = ref(false)
const showImportDialog = ref(false)
const currentQuestion = ref(null)
const currentSubject = ref(null)
const editing = ref(false)
const saving = ref(false)
const importData = ref([])
const importing = ref(false)

// 编辑表单
const editForm = ref({
  id: '',
  subject: '',
  chapter: '',
  type: '',
  difficulty: '',
  content: '',
  options: [],
  answer: '',
  analysis: '',
  images: []
})

// 图片上传相关
const uploadUrl = ref(`${import.meta.env.VITE_SERVER_URL || 'https://practice.insightdata.top:8443'}/api/upload/image`)
const uploadHeaders = ref({
  'Authorization': `Bearer ${localStorage.getItem('token')}`
})

// 搜索表单
const searchForm = reactive({
  keyword: '',
  subject: '',
  type: '',
  difficulty: ''
})

// 分页
const pagination = reactive({
  page: 1,
  limit: 20,
  total: 0
})

// 科目选项
const subjectOptions = ref([])

// 计算属性
const getTypeText = (type) => {
  const typeMap = {
    single: '单选题',
    multiple: '多选题',
    judge: '判断题'
  }
  return typeMap[type] || type
}

const getTypeTagType = (type) => {
  const typeMap = {
    single: 'primary',
    multiple: 'success',
    judge: 'warning'
  }
  return typeMap[type] || 'info'
}

const getDifficultyTagType = (difficulty) => {
  const difficultyMap = {
    '简单': 'success',
    '中等': 'warning',
    '困难': 'danger'
  }
  return difficultyMap[difficulty] || 'info'
}

const getSubjectTagType = (subject) => {
  const subjectMap = {
    '数学': 'primary',
    '语文': 'success',
    '英语': 'warning',
    '物理': 'danger',
    '化学': 'info',
    '生物': 'success',
    '历史': 'warning',
    '地理': 'primary',
    '政治': 'danger',
    '计算机': 'info'
  }
  return subjectMap[subject] || 'info'
}

// 格式化日期
const formatDate = (date) => {
  if (!date) return '-'
  return new Date(date).toLocaleString('zh-CN')
}

// 加载科目列表
const loadSubjects = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.page,
      limit: pagination.limit,
      ...searchForm
    }
    
    // 移除空值
    Object.keys(params).forEach(key => {
      if (params[key] === '') {
        delete params[key]
      }
    })

    const response = await adminAPI.getQuestions(params)
    
    if (response.code === 200) {
      // 按科目分组统计
      const subjectMap = new Map()
      response.data.list.forEach(question => {
        const key = question.subject
        if (!subjectMap.has(key)) {
          subjectMap.set(key, {
            id: key,
            name: question.subject, // 科目名称就是题库名称
            difficulty: question.difficulty,
            questionCount: 0,
            createdAt: question.createdAt
          })
        }
        subjectMap.get(key).questionCount++
      })
      
      subjects.value = Array.from(subjectMap.values())
      pagination.total = subjects.value.length
      
      // 更新科目选项
      const subjectNames = [...new Set(subjects.value.map(s => s.name))]
      subjectOptions.value = subjectNames.filter(s => s)
    } else {
      ElMessage.error(response.message || '获取科目列表失败')
    }
  } catch (error) {
    console.error('加载科目列表失败:', error)
    ElMessage.error('加载科目列表失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

// 加载题目列表
const loadQuestions = async () => {
  if (!currentSubject.value) return
  
  loading.value = true
  try {
    const params = {
      page: pagination.page,
      limit: pagination.limit,
      subject: currentSubject.value.name, // 按科目筛选
      ...searchForm
    }
    
    // 移除空值
    Object.keys(params).forEach(key => {
      if (params[key] === '') {
        delete params[key]
      }
    })

    const response = await adminAPI.getQuestions(params)
    
    console.log('题目列表API响应:', response)
    
    if (response.code === 200) {
      questions.value = response.data.list || []
      pagination.total = response.data.total || 0
      console.log('加载的题目列表:', questions.value)
    } else {
      ElMessage.error(response.message || '获取题目列表失败')
    }
  } catch (error) {
    console.error('加载题目列表失败:', error)
    ElMessage.error('加载题目列表失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.page = 1
  if (currentSubject.value) {
    loadQuestions()
  } else {
    loadSubjects()
  }
}

// 重置搜索
const resetSearch = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = ''
  })
  pagination.page = 1
  if (currentSubject.value) {
    loadQuestions()
  } else {
    loadSubjects()
  }
}

// 分页处理
const handleSizeChange = (size) => {
  pagination.limit = size
  pagination.page = 1
  if (currentSubject.value) {
    loadQuestions()
  } else {
    loadSubjects()
  }
}

const handleCurrentChange = (page) => {
  pagination.page = page
  if (currentSubject.value) {
    loadQuestions()
  } else {
    loadSubjects()
  }
}

// 选择处理
const handleSelectionChange = (selection) => {
  selectedQuestions.value = selection
}

// 进入科目
const enterSubject = (subject) => {
  currentSubject.value = subject
  pagination.page = 1
  loadQuestions()
}

// 返回科目列表
const backToSubjects = () => {
  currentSubject.value = null
  pagination.page = 1
  loadSubjects()
}

// 删除科目
const deleteSubject = async (subject) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除科目"${subject.name}"的所有题目吗？这将删除该科目下的所有题目。`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await adminAPI.deleteQuestionBank(subject.name)
    
    if (response.code === 200) {
      ElMessage.success(`删除成功，共删除 ${response.data.deletedCount} 道题目`)
      loadSubjects()
    } else {
      ElMessage.error(response.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除科目失败:', error)
      ElMessage.error('删除失败: ' + error.message)
    }
  }
}

// 编辑题目
const editQuestion = (question) => {
  currentQuestion.value = question
  showDetailDialog.value = true
  // 直接进入编辑模式
  startEdit()
}

// 开始编辑
const startEdit = () => {
  if (!currentQuestion.value) {
    console.error('currentQuestion is null')
    return
  }
  
  console.log('开始编辑题目:', currentQuestion.value)
  
  // 初始化编辑表单
  editForm.value = {
    id: currentQuestion.value.id,
    subject: currentQuestion.value.subject,
    chapter: currentQuestion.value.chapter || '',
    type: currentQuestion.value.type,
    difficulty: currentQuestion.value.difficulty || '简单',
    content: currentQuestion.value.content,
    options: parseOptions(currentQuestion.value.options),
    answer: currentQuestion.value.answer,
    analysis: currentQuestion.value.analysis || '',
    images: parseImages(currentQuestion.value.images)
  }
  
  console.log('编辑表单初始化完成:', editForm.value)
  editing.value = true
}

// 解析选项数据
const parseOptions = (options) => {
  if (!options) return []
  
  try {
    // 如果是字符串，尝试解析JSON
    if (typeof options === 'string') {
      const parsed = JSON.parse(options)
      if (Array.isArray(parsed)) {
        return parsed.map(option => ({
          content: typeof option === 'string' ? option : option.content || ''
        }))
      }
    }
    
    // 如果是数组
    if (Array.isArray(options)) {
      return options.map(option => ({
        content: typeof option === 'string' ? option : option.content || ''
      }))
    }
    
    return []
  } catch (error) {
    console.error('解析选项失败:', error)
    return []
  }
}

// 解析图片数据
const parseImages = (images) => {
  if (!images) return []
  
  try {
    // 如果是字符串，尝试解析JSON
    if (typeof images === 'string') {
      const parsed = JSON.parse(images)
      if (Array.isArray(parsed)) {
        return parsed.map(image => ({
          name: image.name || 'image',
          url: getImageUrl(image.path || image),
          path: image.path || image
        }))
      }
    }
    
    // 如果是数组
    if (Array.isArray(images)) {
      return images.map(image => ({
        name: image.name || 'image',
        url: getImageUrl(image.path || image),
        path: image.path || image
      }))
    }
    
    return []
  } catch (error) {
    console.error('解析图片失败:', error)
    return []
  }
}

// 获取图片URL
const getImageUrl = (path) => {
  if (!path || typeof path !== 'string') {
    console.warn('无效的图片路径:', path)
    return ''
  }
  if (path.startsWith('http')) return path
  return `${import.meta.env.VITE_SERVER_URL || 'https://practice.insightdata.top:8443'}/uploads/${path}`
}

// 获取图片预览列表
const getImagePreviewList = () => {
  if (!currentQuestion.value?.images) return []
  
  try {
    const images = typeof currentQuestion.value.images === 'string' 
      ? JSON.parse(currentQuestion.value.images) 
      : currentQuestion.value.images
    
    return images
      .filter(image => image && typeof image === 'object' && image.path && typeof image.path === 'string')
      .map(image => getImageUrl(image.path))
  } catch (error) {
    return []
  }
}

// 添加选项
const addOption = () => {
  if (editForm.value.options.length < 6) {
    editForm.value.options.push({ content: '' })
  }
}

// 删除选项
const removeOption = (index) => {
  if (editForm.value.options.length > 2) {
    editForm.value.options.splice(index, 1)
  }
}

// 保存题目
const saveQuestion = async () => {
  if (!editForm.value.content.trim()) {
    ElMessage.error('请输入题目内容')
    return
  }
  
  if (editForm.value.options.length < 2) {
    ElMessage.error('至少需要2个选项')
    return
  }
  
  if (!editForm.value.answer.trim()) {
    ElMessage.error('请输入正确答案')
    return
  }
  
  saving.value = true
  try {
    const updateData = {
      chapter: editForm.value.chapter,
      type: editForm.value.type,
      difficulty: editForm.value.difficulty,
      content: editForm.value.content,
      options: JSON.stringify(editForm.value.options.map(opt => opt.content)),
      answer: editForm.value.answer,
      analysis: editForm.value.analysis,
      images: JSON.stringify(editForm.value.images.map(img => ({ path: img.path })))
    }
    
    const response = await adminAPI.updateQuestion(editForm.value.id, updateData)
    
    if (response.code === 200) {
      ElMessage.success('保存成功')
      editing.value = false
      showDetailDialog.value = false
      loadQuestions()
    } else {
      ElMessage.error(response.message || '保存失败')
    }
  } catch (error) {
    console.error('保存题目失败:', error)
    ElMessage.error('保存失败: ' + error.message)
  } finally {
    saving.value = false
  }
}

// 图片上传成功处理
const handleImageSuccess = (response, file, fileList) => {
  if (response.code === 200) {
    editForm.value.images.push({
      name: file.name,
      url: response.data.url,
      path: response.data.path
    })
    ElMessage.success('图片上传成功')
  } else {
    ElMessage.error(response.message || '图片上传失败')
  }
}

// 图片上传失败处理
const handleImageError = (error, file, fileList) => {
  console.error('图片上传失败:', error)
  ElMessage.error('图片上传失败')
}

// 图片上传前验证
const beforeImageUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB!')
    return false
  }
  return true
}

// 删除题目
const deleteQuestion = async (question) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除题目"${question.content.substring(0, 50)}..."吗？`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await adminAPI.deleteQuestion(question.id)
    
    if (response.code === 200) {
      ElMessage.success('删除成功')
      loadQuestions()
    } else {
      ElMessage.error(response.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除题目失败:', error)
      ElMessage.error('删除失败: ' + error.message)
    }
  }
}

// 文件上传处理
const handleFileChange = (file) => {
  // 这里需要实现文件解析逻辑
  console.log('文件选择:', file)
}

const beforeUpload = (file) => {
  const isExcel = file.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  const isCSV = file.type === 'text/csv' || file.name.endsWith('.csv')
  
  if (!isExcel && !isCSV) {
    ElMessage.error('只能上传 Excel 或 CSV 文件!')
    return false
  }
  
  return true
}

// 导入题目
const handleImport = async () => {
  if (importData.value.length === 0) {
    ElMessage.warning('请先选择要导入的文件')
    return
  }

  importing.value = true
  try {
    const response = await adminAPI.importQuestions(importData.value)
    
    if (response.code === 200) {
      ElMessage.success(`成功导入 ${importData.value.length} 条题目`)
      showImportDialog.value = false
      importData.value = []
      loadQuestions()
    } else {
      ElMessage.error(response.message || '导入失败')
    }
  } catch (error) {
    console.error('导入题目失败:', error)
    ElMessage.error('导入失败: ' + error.message)
  } finally {
    importing.value = false
  }
}

// 组件挂载时加载数据
onMounted(() => {
  loadSubjects()
})
</script>

<style scoped>
.questions-page {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.search-section {
  margin-bottom: 20px;
  padding: 20px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.question-detail {
  max-height: 600px;
  overflow-y: auto;
}

.question-content {
  margin-top: 20px;
}

.question-content h4 {
  margin: 15px 0 10px 0;
  color: #409eff;
}

.question-content p {
  margin: 5px 0;
  line-height: 1.6;
}

.question-content ul {
  margin: 10px 0;
  padding-left: 20px;
}

.question-content li {
  margin: 5px 0;
  line-height: 1.6;
}

.answer-section {
  background-color: #f0f9ff;
  padding: 15px;
  border-radius: 4px;
  border-left: 4px solid #409eff;
}

.answer {
  font-weight: bold;
  color: #67c23a;
}

.import-section {
  max-height: 500px;
  overflow-y: auto;
}

.upload-section {
  margin: 20px 0;
}

.preview-section {
  margin-top: 20px;
}

.preview-section h4 {
  margin-bottom: 10px;
  color: #409eff;
}

/* 题库网格样式 */
.bank-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.bank-card {
  cursor: pointer;
  transition: all 0.3s ease;
}

.bank-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.bank-info {
  margin-bottom: 15px;
}

.bank-name {
  margin: 0 0 10px 0;
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

.bank-meta {
  display: flex;
  gap: 8px;
  margin-bottom: 10px;
}

.bank-stats {
  display: flex;
  gap: 15px;
  font-size: 14px;
  color: #606266;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 4px;
}

.bank-actions {
  display: flex;
  gap: 8px;
  justify-content: flex-end;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.bank-title {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

/* 编辑表单样式 */
.edit-form {
  max-height: 600px;
  overflow-y: auto;
}

.options-editor {
  width: 100%;
}

.option-item {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.option-item .el-input {
  flex: 1;
}

.image-upload-section {
  width: 100%;
}

.upload-tip {
  margin-top: 10px;
  font-size: 12px;
  color: #909399;
}

.images-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 10px;
  margin-top: 10px;
}

.analysis-image {
  width: 100%;
  height: 120px;
  border-radius: 4px;
  cursor: pointer;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style> 