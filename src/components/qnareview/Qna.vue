<template>
  <div v-if="!isLoading">
    <div>
      <div class="qna-header">
        <div class="title">QNA ({{ qnas.content.length }})</div>
        <div class="add-qna">
          <button class="add-btn" @click="addQna(itemId)">문의하기</button>
        </div>
      </div>
      <div class="qna-container">
        <p class="no-content" v-if="qnas.content.length === 0">등록된 문의가 없습니다.</p>
        <ul class="qna-list" v-else>
          <div>
            <li v-for="qna in qnas.content" :key="qna.qnaId" class="qna">
              <div class="question-header" @click="toggleAnswer(qna.questionId)">
                <div>
                  <p class="content-category">{{ qna.qnaCategory }}</p>
                  <p class="content-title">{{ qna.title }}</p>
                  <p class="content-content">{{ qna.content }}</p>
                  <!-- <p>{{ qna.attachment }}</p> -->

                  <span>
                    <img class="review-image" src="@/assets/images/product2.jpg" alt="" />
                  </span>
                  <p>
                    <span>
                      {{ qna.done ? '답변완료 · ' : '답변대기중 · ' }}
                    </span>
                    <span> {{ qna.name }} · {{ formatDate(qna.createdDate) }} </span>
                  </p>
                </div>
                <div>
                  <div v-if="isQnaOwner(qna) && !qna.done">
                    <span class="update" @click="editQna(qna)">수정</span>
                    <span class="delete" @click.stop="deleteQna(qna.questionId)">삭제</span>
                  </div>
                  <div>
                    <button
                      v-if="!qna.done && isAdmin"
                      @click.stop="toggleAnswerForm(qna.questionId)"
                    >
                      답변하기
                    </button>
                    <i
                      v-if="qna.done"
                      :class="[
                        'fa-solid',
                        'fa-chevron-down',
                        { rotated: openStates[qna.questionId] },
                      ]"
                    ></i>
                  </div>
                </div>
              </div>

              <!-- 답변 작성 폼 -->
              <div v-if="answerFormStates[qna.questionId]" class="answer-form">
                <textarea
                  v-model="newAnswers[qna.questionId]"
                  placeholder="답변을 입력하세요..."
                ></textarea>
                <div class="button-group">
                  <button @click="submitAnswer(qna.questionId)" class="submit-btn">제출</button>
                  <button @click="cancelAnswer(qna.questionId)" class="cancel-btn">취소</button>
                </div>
              </div>

              <!-- 기존 답변 표시 -->
              <div v-if="qna.done && openStates[qna.questionId]" class="answer-section">
                <div>
                  <p class="answer-title">답변. NINESCENT 담당자</p>
                  <p class="answer-content">{{ getAnswerContent(qna.questionId) }}</p>
                  <p class="answer-date">{{ formatDate(getAnswerDate(qna.questionId)) }}</p>
                </div>
                <div v-if="isAdmin">
                  <button @click="deleteAnswer(qna.questionId)">삭제</button>
                </div>
              </div>
            </li>
          </div>
        </ul>
      </div>
      <template v-if="qnas.content.length > 0">
        <div class="paginate">
          <vue-awesome-paginate
            :total-items="qnas.totalElements"
            :items-per-page="qnas.pageable.pageSize"
            :max-pages-shown="qnas.totalPages"
            :show-ending-buttons="false"
            v-model="currentPage"
            @click="handlePageChange"
          >
            <template #first-page-button><i class="fa-solid fa-backward-fast"></i></template>
            <template #prev-button><i class="fa-solid fa-caret-left"></i></template>
            <template #next-button><i class="fa-solid fa-caret-right"></i></template>
            <template #last-page-button><i class="fa-solid fa-forward-fast"></i></template>
          </vue-awesome-paginate>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';
import faqnaReviewApi from '@/api/faqnaReviewApi';

const route = useRoute();
const router = useRouter();
const qnas = ref({
  content: [],
  pageable: { pageNumber: 0, pageSize: 5 },
  totalElements: 0,
  totalPages: 0,
});
const answers = ref([]);
const openStates = ref({});
const newAnswers = ref({});
const answerFormStates = ref({}); // 답변 폼의 표시 여부를 관리
const isLoading = ref(true);
const authStore = useAuthStore();

let userNo = 0;
let isAdmin = false;

const qnaId = route.params.qnaId;
const itemId = route.params.id;
const isLogin = ref(false);

const isQnaOwner = (qna) => {
  return qna.userNo === userNo;
};

const currentPage = ref(1);
const pageRequest = ref({ page: 0 });

const handlePageChange = async (page) => {
  currentPage.value = page;
  pageRequest.value.page = page - 1;
  await fetchQnaData();
};

const fetchQnaData = async () => {
  if (!itemId) return;
  isLoading.value = true;
  try {
    const response = await faqnaReviewApi.getQnaPage(itemId, pageRequest.value.page);
    qnas.value = response;

    if (qnas.value.pageable) {
      currentPage.value = qnas.value.pageable.pageNumber + 1;
    }
  } catch (error) {
    console.error('Error fetching qna data', error);
  } finally {
    isLoading.value = false;
  }
};

const getAnswerByQnaId = async (qnaId) => {
  try {
    const response = await faqnaReviewApi.getAnswerByQnaId(qnaId);
    return response;
  } catch (error) {
    console.error('Error fetching answer data', error);
  }
};

const getAnswerContent = (questionId) => {
  const answer = answers.value.find((answer) => answer.questionId === questionId);
  return answer ? answer.answer : 'N/A';
};

const getAnswerDate = (questionId) => {
  const answer = answers.value.find((answer) => answer.questionId === questionId);
  return answer ? answer.createdDate : 'N/A';
};

const toggleAnswer = (questionId) => {
  openStates.value[questionId] = !openStates.value[questionId];
};

const toggleAnswerForm = (questionId) => {
  answerFormStates.value[questionId] = !answerFormStates.value[questionId];
  if (!answerFormStates.value[questionId]) {
    newAnswers.value[questionId] = ''; // 폼을 닫을 때 입력값 초기화
  }
};

const submitAnswer = async (questionId) => {
  try {
    const answerData = {
      questionId: questionId,
      answer: newAnswers.value[questionId],
    };
    await faqnaReviewApi.postAnswer(answerData);
    answerFormStates.value[questionId] = false; // 폼 닫기
    newAnswers.value[questionId] = ''; // 입력값 초기화
    await fetchQnaData(); // 데이터 새로고침
  } catch (error) {
    console.error('Error submitting answer', error);
  }
};

const cancelAnswer = (questionId) => {
  answerFormStates.value[questionId] = false;
  newAnswers.value[questionId] = '';
};

const formatDate = (date) => {
  if (!date || date.length < 6) return 'N/A';

  const year = String(date[0]).slice(2);
  const month = String(date[1]).padStart(2, '0');
  const day = String(date[2]).padStart(2, '0');

  return `${year}.${month}.${day}`;
};

const addQna = (itemId) => {
  if (!isLogin.value) {
    if (confirm('로그인이 필요한 서비스입니다. 로그인 페이지로 이동하시겠습니까?')) {
      router.push({ name: 'Login' });
    }
    return;
  }
  router.push({ name: 'AddQna', params: { itemId } });
};

const editQna = (qna) => {
  router.push({
    name: 'UpdateQna',
    params: {
      itemId: itemId,
      questionId: qna.questionId,
    },
  });
};

const deleteQna = async (questionId) => {
  if (!confirm('정말 삭제하시겠습니까?')) return;
  try {
    await faqnaReviewApi.deleteQna(questionId);
    fetchQnaData();
  } catch (error) {
    console.error('Error deleting qna', error);
  }
};

const deleteAnswer = async (questionId) => {
  const answer = answers.value.find((answer) => answer.questionId === questionId);
  if (!confirm('정말 삭제하시겠습니까?')) return;
  try {
    await faqnaReviewApi.deleteAnswer(answer.answerId);
    fetchQnaData();
  } catch (error) {
    console.error('Error deleting answer', error);
  }
};

onMounted(() => {
  fetchQnaData();
  authStore.loadStoredToken();

  const getUserNo = localStorage.getItem('userNo');
  const getRole = localStorage.getItem('role');

  if (getUserNo) {
    userNo = parseInt(getUserNo);
    isLogin.value = true;
  } else {
    isLogin.value = false;
  }

  isAdmin = getRole === 'ROLE_ADMIN';
});
</script>

<style scoped>
.no-content {
  text-align: center;
  margin: 20px 0px;
}

.qna-container {
  margin: 20px 0px;
  border-top: 1px solid #e0e0e0;
  border-bottom: 1px solid #e0e0e0;
}

.qna-list {
  margin: 0;
  padding: 0;
}

.qna {
  list-style: none;
  border-bottom: 1px solid #ccc;
  padding: 10px;
  display: flex;
  justify-content: space-between;
  flex-direction: column;
}

.question-header {
  display: flex;
  justify-content: space-between;
  /* align-items: center; */
  cursor: pointer;
}

.answer-section {
  margin-top: 10px;
  padding: 10px;
  background-color: #f5f5f5;
  border-radius: 4px;
}

.answer-form {
  margin-top: 10px;
  padding: 10px;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.answer-form textarea {
  width: 100%;
  min-height: 100px;
  margin-bottom: 10px;
  padding: 8px;
  border: 1px solid #e2e1e1;
  border-radius: 4px;
  resize: vertical;
}

.button-group {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

.submit-btn,
.cancel-btn {
  padding: 6px 12px;
  border-radius: 4px;
  cursor: pointer;
}

.submit-btn {
  color: black;
  border: none;
}

.submit-btn:hover,
.cancel-btn:hover {
  background-color: #e96161;
  color: white;
}

.cancel-btn {
  color: black;
  border: none;
}

.fa-chevron-down {
  transition: transform 0.3s ease;
}

.fa-chevron-down.rotated {
  transform: rotate(180deg);
}

.update {
  margin-right: 10px;
  cursor: pointer;
  color: #8a8a8a;
}

.delete {
  cursor: pointer;
  color: #8a8a8a;
}

.content-category {
  margin-bottom: 0px;
}

.content-title {
  font-weight: bold;
  font-size: 1.2rem;
  margin-bottom: 5px;
}

.content-content {
  margin-bottom: 0px;
}

.review-image {
  width: 120px;
  height: 130px;
  margin-top: 10px;
  margin-bottom: 10px;
}

.add-qna {
  text-align: right;
}

.add-btn {
  padding: 5px 15px;
  border-radius: 5px;
  background-color: #ffffff;
}

.answer-title {
  font-weight: 500;
}

.answer-date {
  color: #7a7a7a;
  margin-bottom: 0px;
}

.qna-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 20px;
}

.title {
  font-size: 25px;
}

.paginate {
  text-align: center;
}
</style>
