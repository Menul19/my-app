import customtkinter as ctk
import math

# UI සැකසුම්
ctk.set_appearance_mode("dark") 
ctk.set_default_color_theme("blue")

class MenuScICal(ctk.CTk):
    def __init__(self):
        super().__init__()

        # App Window Settings
        self.title("Menu ScICal")
        self.geometry("450x750")
        self.resizable(False, False)

        # ප්‍රධාන තිරය (Display Screen)
        self.result_var = ctk.StringVar(value="0")
        self.entry = ctk.CTkEntry(self, textvariable=self.result_var, font=("Arial", 32), 
                                 height=80, corner_radius=12, justify="right")
        self.entry.pack(fill="x", padx=20, pady=20)

        # Tab පද්ධතිය (Tabs)
        self.tabview = ctk.CTkTabview(self, corner_radius=15)
        self.tabview.pack(fill="both", expand=True, padx=10, pady=10)
        
        self.tabview.add("Calculator")
        self.tabview.add("Unit Converter")
        self.tabview.add("Settings")
        self.tabview.add("About")

        self.setup_calculator()
        self.setup_unit_converter()
        self.setup_settings()
        self.setup_about()

    # --- Scientific Calculator ---
    def setup_calculator(self):
        tab = self.tabview.tab("Calculator")
        buttons = [
            'sin', 'cos', 'tan', 'C',
            '7', '8', '9', '/',
            '4', '5', '6', '*',
            '1', '2', '3', '-',
            '0', '.', '=', '+'
        ]
        
        frame = ctk.CTkFrame(tab, fg_color="transparent")
        frame.pack(expand=True)

        r, c = 0, 0
        for btn in buttons:
            # බොත්තම් වල පාට සැකසීම
            if btn == "=": color = "#1f6aa5"
            elif btn == "C": color = "#942d2d"
            else: color = "#3b3b3b"
            
            ctk.CTkButton(frame, text=btn, width=90, height=65, corner_radius=10,
                          fg_color=color, font=("Arial", 20, "bold"),
                          command=lambda x=btn: self.calc_logic(x)).grid(row=r, column=c, padx=5, pady=5)
            c += 1
            if c > 3: c = 0; r += 1

    def calc_logic(self, char):
        curr = self.result_var.get()
        if char == "C": 
            self.result_var.set("0")
        elif char == "=":
            try:
                # Math calculations
                expr = curr.replace('sin', 'math.sin(math.radians').replace('cos', 'math.cos(math.radians').replace('tan', 'math.tan(math.radians')
                # වරහන් අඩු නම් සම්පූර්ණ කිරීම
                if 'math.' in expr: expr += ')' * (expr.count('(') - expr.count(')'))
                self.result_var.set(str(round(eval(expr), 8)))
            except: 
                self.result_var.set("Error")
        else:
            self.result_var.set(char if curr == "0" else curr + char)

    # --- Unit Converter (100% Offline) ---
    def setup_unit_converter(self):
        tab = self.tabview.tab("Unit Converter")
        ctk.CTkLabel(tab, text="Advanced Unit Converter", font=("Arial", 18, "bold")).pack(pady=10)
        
        self.unit_val = ctk.CTkEntry(tab, placeholder_text="Enter Value", width=280, height=40)
        self.unit_val.pack(pady=10)
        
        self.unit_mode = ctk.CTkComboBox(tab, values=[
            "Length: CM to Meters", "Length: Meters to CM", 
            "Length: KM to Miles", "Length: Miles to KM",
            "Weight: KG to Grams", "Weight: Grams to KG",
            "Temp: Celsius to Fahrenheit", "Temp: Fahrenheit to Celsius",
            "Volume: Liters to ML"
        ], width=280, height=40)
        self.unit_mode.set("Length: CM to Meters")
        self.unit_mode.pack(pady=10)
        
        ctk.CTkButton(tab, text="Convert Now", fg_color="#2ecc71", text_color="black", 
                      font=("Arial", 16, "bold"), command=self.unit_logic).pack(pady=15)
        
        self.res_label = ctk.CTkLabel(tab, text="Result: --", font=("Arial", 20, "bold"), text_color="#3498db")
        self.res_label.pack(pady=20)

    def unit_logic(self):
        try:
            val = float(self.unit_val.get())
            mode = self.unit_mode.get()
            res, unit = 0, ""

            if "CM to Meters" in mode: res, unit = val / 100, "m"
            elif "Meters to CM" in mode: res, unit = val * 100, "cm"
            elif "KM to Miles" in mode: res, unit = val * 0.6213, "mi"
            elif "Miles to KM" in mode: res, unit = val / 0.6213, "km"
            elif "KG to Grams" in mode: res, unit = val * 1000, "g"
            elif "Grams to KG" in mode: res, unit = val / 1000, "kg"
            elif "Celsius to Fahrenheit" in mode: res, unit = (val * 9/5) + 32, "°F"
            elif "Fahrenheit to Celsius" in mode: res, unit = (val - 32) * 5/9, "°C"
            elif "Liters to ML" in mode: res, unit = val * 1000, "ml"

            self.res_label.configure(text=f"Result: {round(res, 4)} {unit}")
        except:
            self.res_label.configure(text="Invalid Input!", text_color="#e74c3c")

    # --- About & Settings ---
    def setup_about(self):
        tab = self.tabview.tab("About")
        info = "APPLICATION: Menu ScICal\nDeveloper: [ඔබේ නම]\nStatus: Stable Build\nFeatures: Scientific Calc & Unit Converter"
        ctk.CTkLabel(tab, text=info, justify="left", font=("Arial", 14)).pack(pady=30)

    def setup_settings(self):
        tab = self.tabview.tab("Settings")
        ctk.CTkLabel(tab, text="Switch Theme", font=("Arial", 16)).pack(pady=20)
        ctk.CTkSegmentedButton(tab, values=["Dark", "Light"], 
                               command=lambda m: ctk.set_appearance_mode(m.lower())).pack()

if __name__ == "__main__":
    app = MenuScICal()
    app.mainloop()
