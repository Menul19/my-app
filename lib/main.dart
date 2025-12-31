import customtkinter as ctk
import math

# UI සැකසුම්
ctk.set_appearance_mode("dark") 
ctk.set_default_color_theme("blue")

class MenuScICal(ctk.CTk):
    def __init__(self):
        super().__init__()

        # Window Settings
        self.title("Menu ScICal - Pro")
        self.geometry("450x720")
        self.resizable(False, False)

        # Main Screen (Display)
        self.result_var = ctk.StringVar(value="0")
        self.entry = ctk.CTkEntry(self, textvariable=self.result_var, font=("Arial", 32), 
                                 height=75, corner_radius=10, justify="right")
        self.entry.pack(fill="x", padx=20, pady=20)

        # Tab System
        self.tabview = ctk.CTkTabview(self, corner_radius=15)
        self.tabview.pack(fill="both", expand=True, padx=10, pady=10)
        
        self.tabview.add("Calculator")
        self.tabview.add("Unit Converter")
        self.tabview.add("About")
        self.tabview.add("Settings")

        self.setup_calculator()
        self.setup_unit_converter()
        self.setup_about()
        self.setup_settings()

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
            color = "#3b3b3b" if btn not in ['=', 'C'] else ("#1f6aa5" if btn == "=" else "#942d2d")
            ctk.CTkButton(frame, text=btn, width=85, height=60, corner_radius=8,
                          fg_color=color, font=("Arial", 18, "bold"),
                          command=lambda x=btn: self.calc_logic(x)).grid(row=r, column=c, padx=5, pady=5)
            c += 1
            if c > 3: c = 0; r += 1

    def calc_logic(self, char):
        curr = self.result_var.get()
        if char == "C": self.result_var.set("0")
        elif char == "=":
            try:
                # Math functions optimization
                expr = curr.replace('sin', 'math.sin(math.radians').replace('cos', 'math.cos(math.radians').replace('tan', 'math.tan(math.radians')
                if '(' in expr: expr += ')' * (expr.count('(') - expr.count(')'))
                self.result_var.set(str(round(eval(expr), 8)))
            except: self.result_var.set("Error")
        else:
            self.result_var.set(char if curr == "0" else curr + char)

    # --- Full Unit Converter (No Currency Errors) ---
    def setup_unit_converter(self):
        tab = self.tabview.tab("Unit Converter")
        ctk.CTkLabel(tab, text="Select Conversion Type", font=("Arial", 16, "bold")).pack(pady=10)
        
        self.unit_input = ctk.CTkEntry(tab, placeholder_text="Enter Value", width=250)
        self.unit_input.pack(pady=10)
        
        self.unit_type = ctk.CTkComboBox(tab, values=[
            "Length: CM to Meters", "Length: Meters to CM", 
            "Length: KM to Miles", "Length: Miles to KM",
            "Weight: KG to Grams", "Weight: Grams to KG",
            "Temp: Celsius to Fahrenheit", "Temp: Fahrenheit to Celsius",
            "Data: GB to MB", "Data: MB to KB"
        ], width=250)
        self.unit_type.set("Length: CM to Meters")
        self.unit_type.pack(pady=10)
        
        ctk.CTkButton(tab, text="Convert", command=self.unit_logic, fg_color="#2ecc71", text_color="black").pack(pady=10)
        self.unit_res = ctk.CTkLabel(tab, text="Result: --", font=("Arial", 18, "bold"), text_color="#3498db")
        self.unit_res.pack(pady=20)

    def unit_logic(self):
        try:
            val = float(self.unit_input.get())
            mode = self.unit_type.get()
            res, unit = 0, ""

            if "CM to Meters" in mode: res, unit = val / 100, "m"
            elif "Meters to CM" in mode: res, unit = val * 100, "cm"
            elif "KM to Miles" in mode: res, unit = val * 0.621, "mi"
            elif "Miles to KM" in mode: res, unit = val / 0.621, "km"
            elif "KG to Grams" in mode: res, unit = val * 1000, "g"
            elif "Grams to KG" in mode: res, unit = val / 1000, "kg"
            elif "Celsius to Fahrenheit" in mode: res, unit = (val * 9/5) + 32, "°F"
            elif "Fahrenheit to Celsius" in mode: res, unit = (val - 32) * 5/9, "°C"
            elif "GB to MB" in mode: res, unit = val * 1024, "MB"
            elif "MB to KB" in mode: res, unit = val * 1024, "KB"

            self.unit_res.configure(text=f"Result: {round(res, 4)} {unit}", text_color="#3498db")
        except: self.unit_res.configure(text="Invalid Input!", text_color="#e74c3c")

    # --- About Section ---
    def setup_about(self):
        tab = self.tabview.tab("About")
        info = """
        APPLICATION: Menu ScICal
        --------------------------
        Developer: [ඔබේ නම මෙතන දාන්න]
        Version: 2.5.0 (Stable Build)
        
        * ලස්සන UI පද්ධතිය
        * සියලුම ඒකක පරිවර්තන (Unit Conversions)
        * විද්‍යාත්මක ගණනය කිරීම්
        * Light / Dark Mode සහාය
        
        කිසිදු Error එකක් නොමැතිව Offline ක්‍රියා කරයි.
        """
        ctk.CTkLabel(tab, text=info, justify="left", font=("Arial", 14)).pack(pady=30)

    # --- Settings ---
    def setup_settings(self):
        tab = self.tabview.tab("Settings")
        ctk.CTkLabel(tab, text="Change Theme", font=("Arial", 16)).pack(pady=20)
        ctk.CTkSegmentedButton(tab, values=["Dark", "Light"], 
                               command=lambda m: ctk.set_appearance_mode(m.lower())).pack()

if __name__ == "__main__":
    app = MenuScICal()
    app.mainloop()
