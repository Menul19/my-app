import tkinter as tk
from tkinter import messagebox
import customtkinter as ctk
import math
import requests # Live currency data ලබා ගැනීමට

# UI සැකසුම්
ctk.set_appearance_mode("dark") 
ctk.set_default_color_theme("blue")

class ScientificCalculator(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("Menu ScICal")
        self.geometry("450x700")

        # Display screen
        self.result_var = tk.StringVar(value="0")
        self.entry = ctk.CTkEntry(self, textvariable=self.result_var, font=("Arial", 28), height=60, justify="right")
        self.entry.pack(fill="x", padx=20, pady=20)

        # Tab View
        self.tabview = ctk.CTkTabview(self)
        self.tabview.pack(fill="both", expand=True, padx=10, pady=10)
        
        self.tabview.add("Calculator")
        self.tabview.add("Converter")
        self.tabview.add("Currency") # අලුතින් එක් කළ කොටස
        self.tabview.add("Settings")
        self.tabview.add("About")

        self.setup_calculator()
        self.setup_converter()
        self.setup_currency()
        self.setup_settings()
        self.setup_about()

    # --- Scientific Calculator ---
    def setup_calculator(self):
        buttons = [
            '7', '8', '9', '/', 'sin',
            '4', '5', '6', '*', 'cos',
            '1', '2', '3', '-', 'tan',
            '0', '.', '=', '+', 'C'
        ]
        frame = self.tabview.tab("Calculator")
        grid_frame = ctk.CTkFrame(frame)
        grid_frame.pack(pady=10)

        r, c = 0, 0
        for btn_text in buttons:
            ctk.CTkButton(grid_frame, text=btn_text, width=75, height=55, 
                          command=lambda x=btn_text: self.on_calc_click(x)).grid(row=r, column=c, padx=5, pady=5)
            c += 1
            if c > 4: c = 0; r += 1

    def on_calc_click(self, char):
        curr = self.result_var.get()
        if char == "=":
            try:
                # Math functions handle කිරීම
                res = eval(curr.replace('sin', 'math.sin').replace('cos', 'math.cos').replace('tan', 'math.tan'))
                self.result_var.set(str(round(res, 4)))
            except: messagebox.showerror("Error", "ගණනය කිරීම වැරදියි")
        elif char == "C": self.result_var.set("0")
        else:
            if curr == "0": self.result_var.set(char)
            else: self.result_var.set(curr + char)

    # --- Unit Converter (cm to m etc.) ---
    def setup_converter(self):
        frame = self.tabview.tab("Converter")
        ctk.CTkLabel(frame, text="Unit Converter", font=("Arial", 16, "bold")).pack(pady=10)
        
        self.unit_val = ctk.CTkEntry(frame, placeholder_text="Enter Value")
        self.unit_val.pack(pady=10)
        
        self.unit_choice = ctk.CTkSegmentedButton(frame, values=["cm to m", "m to cm", "kg to g"])
        self.unit_choice.set("cm to m")
        self.unit_choice.pack(pady=10)
        
        ctk.CTkButton(frame, text="Convert", command=self.unit_convert_logic).pack(pady=10)
        self.unit_res_label = ctk.CTkLabel(frame, text="Result: -", font=("Arial", 14))
        self.unit_res_label.pack(pady=10)

    def unit_convert_logic(self):
        try:
            val = float(self.unit_val.get())
            mode = self.unit_choice.get()
            if mode == "cm to m": res = val / 100
            elif mode == "m to cm": res = val * 100
            elif mode == "kg to g": res = val * 1000
            self.unit_res_label.configure(text=f"Result: {res}")
        except: self.unit_res_label.configure(text="Invalid Input")

    # --- World Currency Converter (Daily Updates) ---
    def setup_currency(self):
        frame = self.tabview.tab("Currency")
        ctk.CTkLabel(frame, text="Live Currency (Base: USD)", font=("Arial", 16, "bold")).pack(pady=10)
        
        self.curr_amount = ctk.CTkEntry(frame, placeholder_text="Amount in USD")
        self.curr_amount.pack(pady=10)

        self.target_curr = ctk.CTkComboBox(frame, values=["LKR", "INR", "EUR", "GBP", "AUD"])
        self.target_curr.set("LKR")
        self.target_curr.pack(pady=10)

        ctk.CTkButton(frame, text="Get Live Rate", command=self.get_live_currency).pack(pady=10)
        self.curr_res_label = ctk.CTkLabel(frame, text="Converted Amount: -", font=("Arial", 14))
        self.curr_res_label.pack(pady=10)

    def get_live_currency(self):
        try:
            amount = float(self.curr_amount.get())
            target = self.target_curr.get()
            # Free API for currency rates
            url = f"https://api.exchangerate-api.com/v4/latest/USD"
            response = requests.get(url).json()
            rate = response['rates'][target]
            converted = amount * rate
            self.curr_res_label.configure(text=f"{amount} USD = {converted:.2f} {target}")
        except:
            messagebox.showerror("Network Error", "අන්තර්ජාලය පරීක්ෂා කරන්න!")

    # --- Settings ---
    def setup_settings(self):
        frame = self.tabview.tab("Settings")
        ctk.CTkLabel(frame, text="UI Theme Settings", font=("Arial", 16)).pack(pady=20)
        ctk.CTkButton(frame, text="Light Mode", fg_color="gray", command=lambda: ctk.set_appearance_mode("light")).pack(pady=10)
        ctk.CTkButton(frame, text="Dark Mode", fg_color="#242424", command=lambda: ctk.set_appearance_mode("dark")).pack(pady=10)

    # --- About Section ---
    def setup_about(self):
        frame = self.tabview.tab("About")
        info = f"""
        APP: Menu ScICal 
        --------------------------
        Developer: [Menul Mihisara]
        Status: Professional Edition
        Features: Scientific Calc, Unit & 
        Live Currency Converter.
        
        © 2024 All Rights Reserved.
        """
        ctk.CTkLabel(frame, text=info, justify="left", font=("Arial", 13)).pack(pady=30)

if __name__ == "__main__":
    app = ScientificCalculator()
    app.mainloop()
