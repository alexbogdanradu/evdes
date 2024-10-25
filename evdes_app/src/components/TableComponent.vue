<template>
  <div class="custom-table">
    <div v-for="(items, year) in groupedByYear" :key="year" class="year-section">
      <h2>{{ year }}</h2>
      <button @click="exportToExcel">Export Data to Excel</button>

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
          <tr v-for="(item, index) in items" :key="index">
            <td>{{ item.code }}</td>
            <td>{{ item.quantity }} {{ item.unit }}</td>
            <td>{{ item.name }}</td>
            <td>{{ item.month }}</td>
            <td v-html="formattedOutbound(item.outbound)"></td>
            <td><button @click="openAddModal(item.id, item)">✏️</button></td>
            <td><button @click="removeItem(item.id, item)">❌</button></td>
          </tr>
        </tbody>
      </table>

      <button>Raport</button>
    </div>

    <button @click="openAddModal()">+ Adaugă Raport</button>

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
import * as XLSX from 'xlsx';
import { saveAs } from 'file-saver';

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
      wasteList: [
        {
          id: 0,
          code: "105123",
          quantity: 150,
          unit: "Kg",
          name: "Cartan",
          month: "January",
          year: 2023,
          outbound: {
            Stocat: { quantity: 32, unit: "", storageType: "" },
            Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
            Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
            Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
            Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
          },
        },
        {
          id: 1,
          code: "105123",
          quantity: 150,
          unit: "Kg",
          name: "Cartan",
          month: "January",
          year: 2024,
          outbound: {
            Stocat: { quantity: 32, unit: "", storageType: "" },
            Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
            Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
            Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
            Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
          },
        },
        {
          id: 2,
          code: "105123",
          quantity: 150,
          unit: "Kg",
          name: "Cartan",
          month: "January",
          year: 2024,
          outbound: {
            Stocat: { quantity: 32, unit: "", storageType: "" },
            Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
            Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
            Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
            Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
          },
        },
        {
          id: 3,
          code: "105123",
          quantity: 150,
          unit: "Kg",
          name: "Cartan",
          month: "January",
          year: 2024,
          outbound: {
            Stocat: { quantity: 32, unit: "", storageType: "" },
            Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
            Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
            Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
            Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
          },
        }]
    }
  },
  computed: {
    groupedByYear() {
      return this.wasteList.reduce((acc, item) => {
        if (!acc[item.year]) {
          acc[item.year] = [];
        }
        acc[item.year].push(item);
        return acc;
      }, {});
    }
  },
  methods: {
    exportToExcel() {
      // 1. Convert JSON data to a worksheet
      const worksheet = XLSX.utils.json_to_sheet(this.wasteList);

      // 2. Create a new workbook and add the worksheet
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, 'Sheet1');

      // 3. Generate Excel file and save it
      const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' });

      // 4. Create Blob from the Excel buffer
      const blob = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });

      // 5. Trigger the download using FileSaver
      saveAs(blob, 'data-export.xlsx');
    },
    addItemHandler(newItem) {
      if (this.currentYear) {
        this.wasteList[this.currentYear].push(newItem);
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
    openAddModal(itemId = null, item = null) {
      this.isEditMode = !!item;
      this.currentItem = item || {
        code: '',
        quantity: '',
        unit: '',
        name: '',
        month: '',
        year: '',
        outbound: {
          Stocat: { quantity: 0, unit: "", storageType: "" },
          Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
          Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
          Valorificat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
          Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" }
        }
      };
      this.currentItemId = itemId;
      this.isAddModalOpen = true;
    },
    saveItem(updatedItem) {
      if (this.isEditMode && this.currentItemId !== null) {
        const indexOfAltered = this.wasteList.findIndex(x => x.id == this.currentItemId);
        this.wasteList[indexOfAltered] = updatedItem;
      } else {
        const maxId = Math.max(...this.wasteList.map(o => o.id));
        updatedItem.id = maxId + 1;
        this.wasteList.push(updatedItem);
      }

      this.isAddModalOpen = false;
    },
    removeItem(itemId = null, item = null) {
      const isConfirmed = confirm("Are you sure you want to remove this item?");

      if (isConfirmed) {
        this.currentItemId = itemId;
        const indexOfRemoved = this.wasteList.findIndex(x => x.id == this.currentItemId);

        if (indexOfRemoved > -1) {
          this.wasteList.splice(indexOfRemoved, 1);
        }
      }
    }
  },
};
</script>

<style scoped>
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
