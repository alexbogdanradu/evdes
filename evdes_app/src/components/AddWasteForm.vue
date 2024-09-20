<template>
    <div class="add-item-form">
        <h3>Adauga deseu</h3>
        <form @submit.prevent="submitForm">
            <div>
                <label>Cod:</label>
                <input v-model="formData.code" />
            </div>
            <div>
                <label>Cantitate:</label>
                <input v-model.number="formData.quantity" type="number" />
            </div>
            <div>
                <label>Unitate de masura</label>
                <input v-model="formData.unit" />
            </div>
            <div>
                <label>Deseu:</label>
                <input v-model="formData.name" />
            </div>
            <div>
                <label>Luna:</label>
                <input v-model="formData.month" />
            </div>
            <fieldset>
                <legend>Stocat</legend>
                <div>
                    <label>Cantitate:</label>
                    <input v-model.number="formData.outbound.Stocat.quantity" type="number" />
                </div>
                <div>
                    <label>Unitate de masura:</label>
                    <input v-model="formData.outbound.Stocat.unit" />
                </div>
                <div>
                    <label>Mod stocare:</label>
                    <input v-model="formData.outbound.Stocat.storageType" />
                </div>
            </fieldset>
            <fieldset>
                <legend>Tratat</legend>
                <div>
                    <label>Cantitate:</label>
                    <input v-model.number="formData.outbound.Tratat.quantity" type="number" />
                </div>
                <div>
                    <label>Unitate de masura:</label>
                    <input v-model="formData.outbound.Tratat.unit" />
                </div>
                <div>
                    <label>Mod tratare:</label>
                    <input v-model="formData.outbound.Tratat.treatmentMode" />
                </div>
                <div>
                    <label>Scop:</label>
                    <input v-model="formData.outbound.Tratat.treatmentScope" />
                </div>
            </fieldset>
            <fieldset>
                <legend>Transportat</legend>
                <div>
                    <label>Quantity:</label>
                    <input v-model.number="formData.outbound.Transportat.quantity" type="number" />
                </div>
                <div>
                    <label>Unitate de masura:</label>
                    <input v-model="formData.outbound.Transportat.unit" />
                </div>
                <div>
                    <label>Mijloc:</label>
                    <input v-model="formData.outbound.Transportat.meansOfTransportation" />
                </div>
                <div>
                    <label>Destinatie:</label>
                    <input v-model="formData.outbound.Transportat.destination" />
                </div>
            </fieldset>
            <fieldset>
                <legend>Valorificat</legend>
                <div>
                    <label>Cantitate:</label>
                    <input v-model.number="formData.outbound.Valorificat.quantity" type="number" />
                </div>
                <div>
                    <label>Unitate de masura:</label>
                    <input v-model="formData.outbound.Valorificat.unit" />
                </div>
                <div>
                    <label>Cod operatie:</label>
                    <input v-model="formData.outbound.Valorificat.operationCode" />
                </div>
                <div>
                    <label>Procesator:</label>
                    <input v-model="formData.outbound.Valorificat.processingCompany" />
                </div>
            </fieldset>
            <fieldset>
                <legend>Eliminat</legend>
                <div>
                    <label>Cantitate:</label>
                    <input v-model.number="formData.outbound.Eliminat.quantity" type="number" />
                </div>
                <div>
                    <label>Unitate de masura:</label>
                    <input v-model="formData.outbound.Eliminat.unit" />
                </div>
                <div>
                    <label>Cod operatie:</label>
                    <input v-model="formData.outbound.Eliminat.operationCode" />
                </div>
                <div>
                    <label>Procesator:</label>
                    <input v-model="formData.outbound.Eliminat.processingCompany" />
                </div>
            </fieldset>
            <button type="submit" @click="submitForm()">{{ isEdit ? 'Editeaza' : 'Adauga' }} deseu</button>
            <button type="button" @click="$emit('close')">Cancel</button>
        </form>
    </div>
</template>

<script>
export default {
    props: {
        year: {
            type: String,
            required: true,
        },
        item: {
            type: Object,
            default: () => ({}),
        },
        isEdit: {
            type: Boolean,
            default: false,
        },
    },
    watch: {
        item: {
            handler(newValue) {
                this.formData = { ...newValue }; // Update formData when item prop changes
            },
            deep: true, // Deep watch for nested changes
            immediate: true // Trigger handler immediately on component creation
        }
    },
    data() {
        return {
            formData: { ...this.item } // Initialize formData with item prop
        };
        // return {
        //     formData: {
        //         code: '',
        //         quantity: 0,
        //         unit: '',
        //         name: '',
        //         month: '',
        //         outbound: {
        //             Stocat: { quantity: 32, unit: "", storageType: "" },
        //             Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
        //             Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
        //             Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
        //             Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
        //         },
        //     }
        // };
    },
    methods: {
        submitForm() {
            this.$emit('save-item', { ...this.formData });
        }
    }
};
</script>

<style scoped>
/* Add basic styling for form */
</style>