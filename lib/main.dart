import customtkinter as ctk
import math

# UI පෙනුම සැකසීම
ctk.set_appearance_mode("dark") 
ctk.set_default_color_theme("blue")

class MenuScICal(ctk.CTk):
    def __init__(self):
        super().__init__()

        # App Window Settings
        self.title("Menu ScICal - Pro Edition")
        self.geometry("450x700")
        self.resizable(False, False)

        # Display Screen
        self.result_var = ctk.StringVar(value="0")
        self.entry = ctk.CTkEntry(self, textvariable=self.result_var, font=("Arial", 32), 
                                 height=70, corner_radius=10, justify="right")
        self.entry.pack(fill="x", padx=20, pady=20)

        # Tab System
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

    # --- Scientific Calculator Section ---
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
        for btn_text in buttons:
            cmd = lambda x=btn_text: self.on_button_click(x)
            color = "#3b3b3b" if btn_text not in ['=', 'C'] else ("#1f6aa5" if btn_text == "=" else "#942d2d")
            
            ctk.CTkButton(frame, text=btn_text, width=85, height=60, corner_radius=8,
                          fg_color=color, font=("Arial", 18, "bold"),
                          command=cmd).grid(row=r, column=c, padx=5, pady=5)
            c += 1
            if c > 3:
                c = 0
                r += 1

    def on_button_click(self, char):
        current = self.result_var.get()
        if char == "C":
            self.result_var.set("0")
        elif char == "=":
            try:
                # Math functions handle කිරීම
                expr = current.replace('sin', 'math.sin(math.radians')
                expr = expr.replace('cos', 'math.cos(math.radians')
                expr = expr.replace('tan', 'math.tan(math.radians')
                
                # වරහන් ගණන පරීක්ෂා කර සම්පූර්ණ කිරීම
                open_b = expr.count('(')
                close_b = expr.count(')')
                if open_b > close_b:
                    expr += ')' * (open_b - close_b)
                
                result = eval(expr)
                self.result_var.set(str(round(result, 8)))
            except:
                self.result_var.set("Error")
        else:
            if current == "0":
                self.result_var.set(char)
            else:
                self.result_var.set(current + char)

    # --- Full Unit Converter Section ---
    def setup_unit_converter(self):
        tab = self.tabview.tab("Unit Converter")
        
        ctk.CTkLabel(tab, text="Advanced Unit Converter", font=("Arial", 18, "bold")).pack(pady=10)
        
        # අගය ඇතුළත් කරන කොටස
        self.unit_input = ctk.CTkEntry(tab, placeholder_text="Enter Value", width=250)
        self.unit_input.pack(pady=10)
        
        # වර්ගය තේරීමට (Dropdown)
        self.unit_type = ctk.CTkComboBox(tab, values=[
            "CM to Meters", "Meters to CM", 
            "KG to Grams", "Grams to KG",
            "Celsius to Fahrenheit", "Fahrenheit to Celsius",
            "Km to Miles", "Miles to Km"
        ], width=250)
        self.unit_type.set("CM to Meters")
        self.unit_type.pack(pady=10)
        
        ctk.CTkButton(tab, text="Convert Now", command=self.do_conversion, fg_color="#2ecc71", text_color="black").pack(pady=10)
        
        self.unit_output = ctk.CTkLabel(tab, text="Result: --", font=("Arial", 18, "bold"), text_color="#3498db")
        self.unit_output.pack(pady=20)

    def do_conversion(self):
        try:
            val = float(self.unit_input.get())
            mode = self.unit_type.get()
            res = 0
            unit = ""

            if mode == "CM to Meters": res = val / 100; unit = "m"
            elif mode == "Meters to CM": res = val * 100; unit = "cm"
            elif mode == "KG to Grams": res = val * 1000; unit = "g"
            elif mode == "Grams to KG": res = val / 1000; unit = "kg"
            elif mode == "Celsius to Fahrenheit": res = (val * 9/5) + 32; unit = "°F"
            elif mode == "Fahrenheit to Celsius": res = (val - 32) * 5/9; unit = "°C"
            elif mode == "Km to Miles": res = val * 0.621371; unit = "miles"
            elif mode == "Miles to Km": res = val / 0.621371; unit = "km"

            self.unit_output.configure(text=f"Result: {round(res, 4)} {unit}")
        except:
            self.unit_output.configure(text="Invalid Input!", text_color="#e74c3c")

    # --- Settings (Dark/Light Mode) ---
    def setup_settings(self):
        tab = self.tabview.tab("Settings")
        ctk.CTkLabel(tab, text="Switch Theme Mode", font=("Arial", 18, "bold")).pack(pady=20)
        
        def change_mode(choice):
            ctk.set_appearance_mode(choice.lower())

        mode_switch = ctk.CTkSegmentedButton(tab, values=["Dark", "Light"], command=change_mode)
        mode_switch.set("Dark")
        mode_switch.pack(pady=10)

    # --- About Section ---
    def setup_about(self):
        tab = self.tabview.tab("About")
        about_info = """
        APPLICATION: Menu ScICal
        --------------------------
        Developer: [ඔබේ නම මෙතන දාන්න]
        Version: 2.0.0 (Pro)
        
        ඇතුළත් කර ඇති පහසුකම්:
        * Scientific Calculation (sin, cos, tan)
        * All Major Unit Conversions
        * Light / Dark Mode Support
        * Offline Stability (No Errors)
        
        © 2024 All Rights Reserved.
        """
        ctk.CTkLabel(tab, text=about_info, justify="left", font=("Arial", 14)).pack(pady=30)

if __name__ == "__main__":
    app = MenuScICal()
    app.mainloop()
