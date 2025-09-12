<template>
  <div class="dashboard">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stats-cards" v-loading="loading">
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon user-icon">👥</div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.userCount }}</div>
              <div class="stat-label">用户数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon bank-icon">📚</div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.questionCount }}</div>
              <div class="stat-label">题目数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon practice-icon">✍️</div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.practiceCount }}</div>
              <div class="stat-label">做题量</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon error-icon">❌</div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.errorRate }}%</div>
              <div class="stat-label">错题率</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 快捷入口 -->
    <el-row :gutter="20" class="quick-actions">
      <el-col :span="24">
        <el-card>
          <template #header>
            <span class="card-title">快捷入口</span>
          </template>
          <div class="action-buttons">
            <el-button type="primary" @click="smartImport">
              <el-icon><Upload /></el-icon>
              智能导入
            </el-button>
            <el-button type="success" @click="showExportDialog = true">
              <el-icon><Download /></el-icon>
              导出题库
            </el-button>
            <el-button type="warning" @click="addAnnouncement">
              <el-icon><Bell /></el-icon>
              新增公告
            </el-button>
            <el-button type="info" @click="viewStatistics">
              <el-icon><DataAnalysis /></el-icon>
              数据统计
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 公告栏 -->
    <el-row :gutter="20" class="announcement-section">
      <el-col :span="12">
        <el-card>
          <template #header>
            <span class="card-title">系统公告</span>
          </template>
          <div class="announcement-list">
            <div v-for="announcement in announcements" :key="announcement.id" class="announcement-item">
              <div class="announcement-title">{{ announcement.title }}</div>
              <div class="announcement-content">{{ announcement.content }}</div>
              <div class="announcement-time">{{ announcement.time }}</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 数据趋势图表 -->
      <el-col :span="12">
        <el-card>
          <template #header>
            <span class="card-title">数据趋势</span>
          </template>
          <div class="chart-container">
            <div ref="chartRef" class="chart"></div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 导出题库对话框 -->
    <el-dialog v-model="showExportDialog" title="导出题库" width="500px">
      <el-form :model="exportForm" label-width="100px">
        <el-form-item label="选择题库" required>
          <el-select v-model="exportForm.questionBankId" placeholder="请选择要导出的题库" style="width: 100%" @change="handleQuestionBankChange">
            <el-option
              v-for="bank in questionBanks"
              :key="bank.id"
              :label="bank.name"
              :value="bank.id"
            >
              <span style="float: left">{{ bank.name }}</span>
              <span style="float: right; color: #8492a6; font-size: 13px">
                {{ bank.subjectCount }}个科目 {{ bank.questionCount }}道题目
              </span>
            </el-option>
          </el-select>
        </el-form-item>
        
        <el-form-item label="导出格式">
          <el-radio-group v-model="exportForm.format">
            <el-radio label="excel">Excel格式 (.xlsx)</el-radio>
            <el-radio label="json">JSON格式 (.json)</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="题库信息" v-if="selectedQuestionBank">
          <div class="question-bank-info">
            <p><strong>题库名称：</strong>{{ selectedQuestionBank.name }}</p>
            <p><strong>题库描述：</strong>{{ selectedQuestionBank.description || '暂无描述' }}</p>
            <p><strong>科目数量：</strong>{{ selectedQuestionBank.subjectCount }}个</p>
            <p><strong>题目数量：</strong>{{ selectedQuestionBank.questionCount }}道</p>
          </div>
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showExportDialog = false">取消</el-button>
          <el-button 
            type="primary" 
            @click="handleExport"
            :loading="exporting"
            :disabled="!exportForm.questionBankId"
          >
            <el-icon><Download /></el-icon>
            开始导出
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import { adminAPI } from '../api/admin'
import { questionBankAPI } from '../api/questionBank'

const router = useRouter()

// 统计数据
const stats = reactive({
  userCount: 0,
  questionCount: 0,
  practiceCount: 0,
  errorRate: 0
})

// 加载状态
const loading = ref(true)

// 公告数据
const announcements = ref([
  {
    id: 1,
    title: '系统维护通知',
    content: '系统将于今晚22:00-24:00进行维护升级，期间可能影响正常使用。',
    time: '2024-01-15 10:30'
  },
  {
    id: 2,
    title: '新功能上线',
    content: '错题本功能已正式上线，用户可查看和管理错题。',
    time: '2024-01-14 15:20'
  },
  {
    id: 3,
    title: '活动通知',
    content: '春节答题活动即将开始，参与可获得积分奖励。',
    time: '2024-01-13 09:15'
  }
])

// 图表引用
const chartRef = ref(null)
let chart = null

// 导出相关数据
const showExportDialog = ref(false)
const exporting = ref(false)
const questionBanks = ref([])
const selectedQuestionBank = ref(null)
const exportForm = reactive({
  questionBankId: '',
  format: 'excel'
})

// 加载统计数据
const loadStats = async () => {
  try {
    loading.value = true
    console.log('开始加载统计数据...')
    
    // 获取统计数据
    const response = await adminAPI.getStats()
    console.log('统计数据响应:', response)
    
    if (response.code === 200) {
      const data = response.data
      stats.userCount = data.userCount || 0
      stats.questionCount = data.questionCount || 0
      stats.practiceCount = data.practiceCount || 0
      stats.errorRate = data.errorRate || 0
      
      // 处理图表数据
      if (data.dailyStats && data.dailyStats.length > 0) {
        chartData.value.dates = data.dailyStats.map(item => {
          const date = new Date(item.date)
          return `${date.getMonth() + 1}月${date.getDate()}日`
        })
        chartData.value.practiceData = data.dailyStats.map(item => item.count)
      } else {
        // 如果没有数据，显示最近7天的空数据
        const dates = []
        const practiceData = []
        for (let i = 6; i >= 0; i--) {
          const date = new Date()
          date.setDate(date.getDate() - i)
          dates.push(`${date.getMonth() + 1}月${date.getDate()}日`)
          practiceData.push(0)
        }
        chartData.value.dates = dates
        chartData.value.practiceData = practiceData
      }
      
      // 初始化图表
      initChart()
      
      console.log('统计数据加载成功:', stats)
      console.log('图表数据:', chartData.value)
    } else {
      console.error('获取统计数据失败:', response.message)
      ElMessage.error('获取统计数据失败: ' + response.message)
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
    ElMessage.error('加载统计数据失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

// 快捷操作
const smartImport = () => {
  router.push('/smart-question-import')
}

// 加载题库列表
const loadQuestionBanks = async () => {
  try {
    const response = await questionBankAPI.getQuestionBanks({ limit: 1000 })
    if (response.code === 200) {
      questionBanks.value = response.data.list || []
    } else {
      ElMessage.error(response.message || '获取题库列表失败')
    }
  } catch (error) {
    console.error('加载题库列表失败:', error)
    ElMessage.error('加载题库列表失败: ' + error.message)
  }
}

// 题库选择变化处理
const handleQuestionBankChange = (questionBankId) => {
  selectedQuestionBank.value = questionBanks.value.find(bank => bank.id === questionBankId)
}

// 导出题库
const handleExport = async () => {
  if (!exportForm.questionBankId) {
    ElMessage.error('请选择题库')
    return
  }

  exporting.value = true
  try {
    const blob = await adminAPI.exportQuestionBank(exportForm.questionBankId, exportForm.format)
    
    // 检查blob是否有效
    if (!blob || blob.size === 0) {
      throw new Error('导出文件为空')
    }
    
    // 创建下载链接
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    
    // 设置文件名，确保文件名合法
    const questionBank = questionBanks.value.find(bank => bank.id === exportForm.questionBankId)
    const sanitizedName = questionBank.name.replace(/[<>:"/\\|?*]/g, '_')
    const extension = exportForm.format === 'excel' ? 'xlsx' : 'json'
    const fileName = `${sanitizedName}_题库导出.${extension}`
    link.download = fileName
    
    // 触发下载
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    
    // 清理URL对象
    window.URL.revokeObjectURL(url)
    
    ElMessage.success('题库导出成功')
    showExportDialog.value = false
    
    // 重置表单
    exportForm.questionBankId = ''
    exportForm.format = 'excel'
    selectedQuestionBank.value = null
  } catch (error) {
    console.error('导出题库失败:', error)
    ElMessage.error('导出题库失败: ' + error.message)
  } finally {
    exporting.value = false
  }
}

const addAnnouncement = () => {
  ElMessage.success('跳转到公告发布页面')
}

const viewStatistics = () => {
  ElMessage.success('跳转到数据统计页面')
}

// 图表数据
const chartData = ref({
  dates: [],
  practiceData: [],
  userData: []
})

// 初始化图表
const initChart = () => {
  if (chartRef.value) {
    chart = echarts.init(chartRef.value)
    updateChart()
  }
}

// 更新图表数据
const updateChart = () => {
  if (!chart) return
  
  const option = {
    title: {
      text: '近7天活跃度趋势',
      left: 'center',
      textStyle: {
        fontSize: 14,
        color: '#333'
      }
    },
    tooltip: {
      trigger: 'axis',
      formatter: function(params) {
        let result = params[0].name + '<br/>'
        params.forEach(param => {
          result += param.marker + param.seriesName + ': ' + param.value + '<br/>'
        })
        return result
      }
    },
    legend: {
      data: ['做题量'],
      bottom: 10
    },
    xAxis: {
      type: 'category',
      data: chartData.value.dates,
      axisLabel: {
        rotate: 45
      }
    },
    yAxis: {
      type: 'value',
      name: '数量'
    },
    series: [
      {
        name: '做题量',
        type: 'bar',
        data: chartData.value.practiceData,
        itemStyle: {
          color: '#67C23A'
        },
        emphasis: {
          itemStyle: {
            color: '#85ce61'
          }
        }
      }
    ]
  }
  
  chart.setOption(option)
}

// 监听窗口大小变化
const handleResize = () => {
  if (chart) {
    chart.resize()
  }
}

onMounted(async () => {
  await loadStats()
  await loadQuestionBanks()
  // 图表初始化在loadStats中完成，这里只需要添加resize监听
  window.addEventListener('resize', handleResize)
})

// 组件卸载时清理
onUnmounted(() => {
  if (chart) {
    chart.dispose()
  }
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.dashboard {
  padding: 20px;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.stats-cards {
  margin-bottom: 20px;
}

.stat-card {
  height: 120px;
}

.stat-content {
  display: flex;
  align-items: center;
  height: 100%;
}

.stat-icon {
  font-size: 48px;
  margin-right: 20px;
}

.stat-info {
  flex: 1;
}

.stat-number {
  font-size: 32px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.quick-actions {
  margin-bottom: 20px;
}

.card-title {
  font-size: 16px;
  font-weight: bold;
  color: #303133;
}

.action-buttons {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.action-buttons .el-button {
  display: flex;
  align-items: center;
  gap: 5px;
}

.announcement-section {
  margin-bottom: 20px;
}

.announcement-list {
  max-height: 300px;
  overflow-y: auto;
}

.announcement-item {
  padding: 15px 0;
  border-bottom: 1px solid #ebeef5;
}

.announcement-item:last-child {
  border-bottom: none;
}

.announcement-title {
  font-size: 14px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 8px;
}

.announcement-content {
  font-size: 13px;
  color: #606266;
  line-height: 1.5;
  margin-bottom: 8px;
}

.announcement-time {
  font-size: 12px;
  color: #909399;
}

.chart-container {
  height: 300px;
}

.chart {
  width: 100%;
  height: 100%;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .dashboard {
    padding: 10px;
  }
  
  .stats-cards .el-col {
    margin-bottom: 10px;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .action-buttons .el-button {
    width: 100%;
  }
}

/* 导出对话框样式 */
.dialog-footer {
  text-align: right;
}

.question-bank-info {
  background-color: #f5f7fa;
  padding: 15px;
  border-radius: 4px;
  border: 1px solid #e4e7ed;
}

.question-bank-info p {
  margin: 8px 0;
  color: #606266;
  font-size: 14px;
}

.question-bank-info strong {
  color: #303133;
}
</style> 