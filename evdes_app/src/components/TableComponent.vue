<template>
  <div class="p-4 mb-4 bg-green-200 rounded-lg overflow-clip" v-for="(items, year) in groupedByYear" :key="year">
    <div class="flex items-center justify-between">
      <div class="p-1 rounded shadow-md bg-green-500">
        <h2 class="text-3xl font-bold text-black">{{ year }}</h2>
      </div>
      <div class="space-x-2">
        <button
          class="px-4 py-2 bg-green-500 hover:bg-green-100 hover:text-black text-white font-semibold rounded shadow-md focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75">
          Raport
        </button>
        <button
          class="px-4 py-2 bg-green-500 hover:bg-green-100 hover:text-black text-white font-semibold rounded shadow-md focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75"
          @click="exportToExcel">Export catre Excel</button>
      </div>
    </div>

    <div class="pt-3">
      <table class="pb-2 min-w-full border border-gray-300 bg-white rounded-lg shadow-md">
        <thead>
          <tr>
            <th class="px-4 py-3 border-b font-semibold text-center text-gray-600 w-20">Luna</th>
            <th class="px-4 py-3 border-b font-semibold text-center text-gray-600 w-40">Cod deseu</th>
            <th class="px-4 py-3 border-b font-semibold text-center text-gray-600 w-20">Generat</th>
            <th class="px-4 py-3 border-b font-semibold text-center text-gray-600 w-fit">Descriere deseu
            </th>
            <th class="px-4 py-3 border-b font-semibold text-center text-gray-600 w-72">Tratare/Eliminare</th>
            <th class="px-4 py-3 border-b font-semibold text-gray-600 w-12">Editeaza</th>
            <th class="px-4 py-3 border-b font-semibold text-gray-600 w-12">Sterge</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, index) in items" :key="index" class="hover:bg-gray-50">
            <td class="px-4 py-2 border-b text-gray-700 text-center">{{ item.month }}</td>
            <td class="px-4 py-2 border-b text-gray-700 text-center">{{ item.code }}</td>
            <td class="px-4 py-2 border-b text-gray-700 text-center">{{ item.quantity }} {{ item.unit }}</td>
            <td class="px-4 py-2 border-b text-gray-700 text-center">{{ item.name }}</td>

            <td class="px-4 py-2 border-b text-gray-700 text-center" v-html="formattedOutbound(item.outbound)"></td>
            <td class="px-4 py-2 border-b text-gray-700 w-12">
              <button @click="openAddModal(item.id, item)"
                class="px-3 py-1 bg-blue-100 hover:bg-blue-600 text-white rounded">
                ✏️
              </button>
            </td>
            <td class="px-4 py-2 border-b text-gray-700 w-12">
              <button @click="removeItem(item.id, item)"
                class="px-3 py-1 bg-red-100 hover:bg-red-300 text-white rounded">
                ❌
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="isAddModalOpen" class="modal">
      <div class="modal-content">
        <AddWasteForm :year="currentYear" :item="currentItem" :isEdit="isEditMode" @save-item="saveItem"
          @close="isAddModalOpen = false" />
      </div>
    </div>
  </div>

  <div class="">
    <button
      class="px-4 py-2 float-left bg-green-500 hover:bg-green-100 hover:text-black text-white font-semibold rounded shadow-md focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75"
      @click="openAddModal()">+ Adaugă Raport</button>
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
          name: "Carton",
          month: "Ianuarie",
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
          name: "Carton",
          month: "Ianuarie",
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
          name: "Carton",
          month: "Ianuarie",
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
          name: "Carton",
          month: "Ianuarie",
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
        const value = outbound[key]?.quantity || 0;
        const isHighlighted = value > 0;

        return `
      <button 
        class="
          px-3 py-1 m-1 
          text-white 
          font-semibold 
          rounded 
          ${isHighlighted ? 'bg-green-500 hover:bg-green-100 hover:text-black' : 'bg-gray-300'}
        "
      >
        ${initials[index]}
      </button>
    `;
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
