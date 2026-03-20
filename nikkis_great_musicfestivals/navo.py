import os

layout_path = os.path.join('src', 'layouts', 'MainLayout.vue')

# Read the existing content to replace the bottom section
with open(layout_path, 'r') as f:
    content = f.read()

# We are injecting a 'sticky' footer into the q-drawer
newsletter_insertion = """
      <div class="absolute-bottom q-pa-md bg-dark border-top-gold">
        <div class="text-caption text-gold q-mb-xs">JOIN THE FESTIVAL NEWS</div>
        <q-input 
          v-model="navEmail" 
          dark 
          dense 
          filled 
          placeholder="Email address"
          class="mardi-input"
        >
          <template v-slot:after>
            <q-btn round dense flat icon="send" color="gold" @click="handleSubscribe" />
          </template>
        </q-input>
      </div>
    </q-drawer>
"""

# Update the script section to include navEmail and handleSubscribe
script_updates = """
const navEmail = ref('')
const handleSubscribe = () => {
  if(navEmail.value) {
    console.log('Subscribing:', navEmail.value)
    // Logic for Supabase call will go here
    navEmail.value = ''
  }
}
"""

# Note: This is a simplified replacement for demonstration. 
# In a real scenario, you'd use a regex or string split to inject these precisely.
print("🛠️ Injecting Newsletter Form into MainLayout.vue...")
# (Manual replacement logic would go here or you can overwrite the file with the full content)
