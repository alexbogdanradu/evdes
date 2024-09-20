<template>
  <div class="custom-table">
    <!-- Loop for Each Year Section -->
    <div v-for="(yearItems, year) in dataByYear" :key="year" class="year-section">
      <h2>{{ year }}</h2>

      <!-- Table Structure -->
      <table>
        <thead>
          <tr>
            <th>Code</th>
            <th>Quantity</th>
            <th>Name</th>
            <th>Month</th>
            <th>Outbound</th>
            <th>Edit</th>
            <th>Delete</th>
          </tr>
        </thead>
        <tbody>
          <!-- Loop for Each Row in the Year -->
          <tr v-for="(year, item, index) in yearItems" :key="index">
            <td>{{ item.code }}</td>
            <td>{{ item.quantity }} {{ item.unit }}</td>
            <td>{{ item.name }}</td>
            <td>{{ item.month }}</td>
            <!-- Use v-html to render the STTVE string with HTML tags -->
            <td v-html="formattedOutbound(item.outbound)"></td>
            <td><button @click="openAddModal(year, index, item)">✏️</button></td>
            <td><button @click="removeItem(year, index)">❌</button></td>
          </tr>
        </tbody>
      </table>

      <!-- Add and Report Buttons -->
      <button @click="openAddModal(year)">+ Adaugă</button>
      <button>Raport</button>
    </div>

    <!-- Global Add Report Button -->
    <button>+ Adaugă Raport</button>

    <!-- Add Item Modal -->
    <div v-if="isAddModalOpen" class="modal">
      <div class="modal-content">
        <AddWasteForm :year="currentYear" :item="currentItem" :isEdit="isEditMode" @save-item="saveItem"
          @close="isAddModalOpen = false" />
      </div>
    </div>
  </div>
</template>

<script>
import AddWasteForm from './AddWasteForm.vue';

export default {
  components: {
    AddWasteForm
  },
  data() {
    return {
      isAddModalOpen: false,
      isEditMode: false,
      currentYear: null,
      currentItem: null,
      currentItemIndex: null,
      dataByYear: {
        2023: [
          {
            code: "105123",
            quantity: 150,
            unit: "Kg",
            name: "Cartan",
            month: "January",
            outbound: {
              Stocat: { quantity: 32, unit: "", storageType: "" },
              Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
              Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
              Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
              Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
            },
          },
          // Additional rows...
        ],
        // Additional years...
        2024: [
          {
            code: "105123",
            quantity: 150,
            unit: "Kg",
            name: "Cartan",
            month: "January",
            outbound: {
              Stocat: { quantity: 32, unit: "", storageType: "" },
              Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
              Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
              Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
              Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
            },
          },
          // Additional rows...
        ],
        2025: [
          {
            code: "105123",
            quantity: 150,
            unit: "Kg",
            name: "Cartan",
            month: "January",
            outbound: {
              Stocat: { quantity: 32, unit: "", storageType: "" },
              Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
              Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
              Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
              Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
            },
          },
          // Additional rows...
        ],
        2026: [
          {
            code: "105123",
            quantity: 150,
            unit: "Kg",
            name: "Cartan",
            month: "January",
            outbound: {
              Stocat: { quantity: 32, unit: "", storageType: "" },
              Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
              Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
              Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
              Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
            },
          },
          // Additional rows...
        ],
      },
    };
  },
  methods: {
    addItemHandler(newItem) {
      if (this.currentYear) {
        this.dataByYear[this.currentYear].push(newItem);
      }
      this.isAddModalOpen = false;
    },
    formattedOutbound(outbound) {
      const keys = ['Stocat', 'Tratat', 'Transportat', 'Valorificat', 'Eliminat'];
      const initials = ['S', 'T', 'T', 'V', 'E'];

      return keys.map((key, index) => {
        const value = outbound[key].quantity;
        return value > 0 ? `<u>${initials[index]}</u>` : initials[index];
      }).join('');
    },
    openAddModal(year, index = null, item = null) {
      this.currentYear = year;
      this.isEditMode = item !== null;
      this.currentItem = item || { // Default values for a new item
        code: '',
        quantity: '',
        unit: '',
        name: '',
        month: '',
        outbound: {
          Stocat: { quantity: 32, unit: "", storageType: "" },
          Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
          Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
          Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
          Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
        }
      };
      this.currentItemIndex = index;
      this.isAddModalOpen = true;
    },
    saveItem(updatedItem) {
      if (this.isEditMode && this.currentItemIndex !== null) {
        // Update the existing item directly without using this.$set
        this.dataByYear[this.currentYear][this.currentItemIndex] = updatedItem;
      } else {
        // Add a new item to the array
        this.dataByYear[this.currentYear].push(updatedItem);
      }
      this.isAddModalOpen = false;
    },
    editItem(year, index) {
      this.openAddModal(year, index, this.dataByYear[year][index]);
    },
    removeItem(year, index) {
      this.dataByYear[year].splice(index, 1);
    },
  },
};
</script>

<style scoped>
/* Basic styling for modal */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
}

.modal-content {
  background-color: white;
  padding: 20px;
  border-radius: 5px;
}
</style>
