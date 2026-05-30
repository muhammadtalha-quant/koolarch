local environment_variables = {
    QT_QPA_PLATFORM = "wayland",
    QT_QPA_PLATFORMTHEME = "qt6ct",
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1"
}


for variable_key,variable_value in pairs(environment_variables) do
    hl.env(variable_key, variable_value)
end
